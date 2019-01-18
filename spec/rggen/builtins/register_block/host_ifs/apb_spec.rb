require_relative '../../spec_helper'

describe "register_block/apb" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, [:address_width, :data_width, :unfold_sv_interface_port]
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:host_if, :clock_reset]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, [:indirect, :external]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, :rw
  end

  after(:all) do
    clear_enabled_items
  end

  describe 'configuration' do
    before(:all) do
      @factory  = build_configuration_factory
    end

    let(:factory) do
      @factory
    end

    def configuration(load_data = {})
      ConfigurationDummyLoader.load_data(load_data)
      @factory.create(configuration_file)
    end

    it "apb選択時、アドレス幅は32ビット以下で使用できる" do
      expect {
        configuration(host_if: :apb, address_width: 8)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, address_width: 16)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, address_width: 32)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, address_width: 33)
      }.to raise_configuration_error 'apb supports 32 or less bits address width only: 33'
      expect {
        configuration(host_if: :apb, address_width: 64)
      }.to raise_configuration_error 'apb supports 32 or less bits address width only: 64'
    end

    it "apb選択時、データ幅は32ビット以下で使用できる" do
      expect {
        configuration(host_if: :apb, data_width: 8)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, data_width: 16)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, data_width: 32)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, data_width: 64)
      }.to raise_configuration_error 'apb supports 32 or less bits data width only: 64'
      expect {
        configuration(host_if: :apb, data_width: 128)
      }.to raise_configuration_error 'apb supports 32 or less bits data width only: 128'
    end
  end

  describe 'rtl' do
    let(:data_width) { 32 }

    let(:address_width) { 32 }

    let(:byte_size) { 252 }

    let(:local_address_width) { Math.clog2(byte_size) }

    let(:configuration) do
      create_configuration(
        host_if: :apb,
        data_width: data_width,
        address_width: address_width,
        unfold_sv_interface_port: unfold_sv_interface_port
      )
    end

    let(:register_map) do
      create_register_map(
        configuration,
        "block_0" => [
          [nil, nil         , "block_0"                                                                                                 ],
          [nil, nil         , byte_size                                                                                                 ],
          [                                                                                                                             ],
          [                                                                                                                             ],
          [nil, "register_0", "0x00"     , nil    , nil                                     , "bit_field_0_0", "[0]"    , "rw", 0  , nil],
          [nil, nil         , nil        , nil    , nil                                     , "bit_field_0_1", "[31:16]", "rw", 0  , nil],
          [nil, "register_1", "0x04"     , nil    , nil                                     , "bit_field_1_0", "[31:0]" , "rw", 0  , nil],
          [nil, "register_2", "0x08-0x0F", "[2]"  , nil                                     , "bit_field_2_0", "[31:0]" , "rw", 0  , nil],
          [nil, "register_3", "0x10"     , "[2,4]", "indirect: bit_field_0_0, bit_field_0_1", "bit_field_3_0", "[31:0]" , "rw", 0  , nil],
          [nil, "register_4", "0x14"     , nil    , :external                               , nil            , nil      , nil , nil, nil],
          [nil, "register_5", "0x18"     , nil    , :external                               , nil            , nil      , nil , nil, nil]
        ]
      )
    end

    let(:rtl) do
      build_rtl_factory.create(configuration, register_map).register_blocks[0]
    end

    context "unfold_sv_interface_portにfalseが設定されている場合" do
      let(:unfold_sv_interface_port) do
        [false, nil, 'false', 'nil', 'off', 'no'].shuffle.first
      end

      it "rggen_apb_ifを入出力ポートに持つ" do
        expect(rtl).to have_interface_port(:register_block, :apb_if, type: :rggen_apb_if, modport: :slave)
      end

      it "APB用のホストIFモジュールをインスタンスするコードを出力する" do
        expected_code =<<'CODE'
rggen_host_if_apb #(
  .LOCAL_ADDRESS_WIDTH  (8),
  .DATA_WIDTH           (32),
  .TOTAL_REGISTERS      (14)
) u_host_if (
  .clk          (clk),
  .rst_n        (rst_n),
  .apb_if       (apb_if),
  .register_if  (register_if)
);
CODE
        expect(rtl).to generate_code(:register_block, :top_down, expected_code)
      end
    end

    context "unfold_sv_interface_portにfalseが設定されている場合" do
      let(:unfold_sv_interface_port) do
        [true, 'true', 'on', 'yes'].shuffle.first
      end

      it "APB用の入出力ポートを持つ" do
        expect(rtl).to have_input(:register_block, :psel, name: 'i_psel', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :penable, name: 'i_penable', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :paddr, name: 'i_paddr', data_type: :logic, width: local_address_width)
        expect(rtl).to have_input(:register_block, :pprot, name: 'i_pprot', data_type: :logic, width: 3)
        expect(rtl).to have_input(:register_block, :pwrite, name: 'i_pwrite', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :pwdata, name: 'i_pwdata', data_type: :logic, width: data_width)
        expect(rtl).to have_input(:register_block, :pstrb, name: 'i_pstrb', data_type: :logic, width: data_width / 8)
        expect(rtl).to have_output(:register_block, :pready, name: 'o_pready', data_type: :logic, width: 1)
        expect(rtl).to have_output(:register_block, :prdata, name: 'o_prdata', data_type: :logic, width: data_width)
        expect(rtl).to have_output(:register_block, :pslverr, name: 'o_pslverr', data_type: :logic, width: 1)
      end

      it "rggen_apb_ifのインスタンスを持つ" do
        expect(rtl). to have_interface(:register_block, :apb_if, type: :rggen_apb_if, name: 'apb_if', parameters: [local_address_width, data_width])
      end

      it "APB用のホストIFモジュールをインスタンスするコード(IF接続含む)を出力する" do
        expected_code =<<'CODE'
assign apb_if.psel = i_psel;
assign apb_if.penable = i_penable;
assign apb_if.paddr = i_paddr;
assign apb_if.pprot = i_pprot;
assign apb_if.pwrite = i_pwrite;
assign apb_if.pwdata = i_pwdata;
assign apb_if.pstrb = i_pstrb;
assign o_pready = apb_if.pready;
assign o_prdata = apb_if.prdata;
assign o_pslverr = apb_if.pslverr;
rggen_host_if_apb #(
  .LOCAL_ADDRESS_WIDTH  (8),
  .DATA_WIDTH           (32),
  .TOTAL_REGISTERS      (14)
) u_host_if (
  .clk          (clk),
  .rst_n        (rst_n),
  .apb_if       (apb_if),
  .register_if  (register_if)
);
CODE
        expect(rtl).to generate_code(:register_block, :top_down, expected_code)
      end
    end
  end
end
