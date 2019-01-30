require_relative '../../spec_helper'

describe 'register_block/axi4lite' do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, [:address_width, :data_width, :array_port_format, :unfold_sv_interface_port]
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:host_if, :clock_reset]
    enable :register_block, :host_if, :axi4lite
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

    it "axi4lite選択時、データ幅は32, 64ビットのみ選択できる" do
      expect {
        configuration(host_if: :axi4lite, data_width: 32)
      }.not_to raise_error
      expect {
        configuration(host_if: :axi4lite, data_width: 64)
      }.not_to raise_error
      expect {
        configuration(host_if: :axi4lite, data_width: 16)
      }.to raise_configuration_error 'axi4lite supports either 32 or 64 bits data width only: 16'
      expect {
        configuration(host_if: :axi4lite, data_width: 128)
      }.to raise_configuration_error 'axi4lite supports either 32 or 64 bits data width only: 128'
    end
  end

  describe 'rtl' do
    let(:data_width) { 32 }

    let(:address_width) { 16 }

    let(:byte_size) { 252 }

    let(:local_address_width) { Math.clog2(byte_size) }

    let(:unfold_sv_interface_port) { [true, false].shuffle.first }

    let(:configuration) do
      create_configuration(host_if: :axi4lite, data_width: 32, address_width: 16, unfold_sv_interface_port: unfold_sv_interface_port)
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

    it "読み書きの優先度を決めるパラメータを持つ" do
      expect(rtl).to have_parameter(:register_block, :access_priority, name: 'ACCESS_PRIORITY', data_type: :'rggen_rtl_pkg::rggen_direction', default: :'rggen_rtl_pkg::RGGEN_WRITE')
    end

    context "unfold_sv_interface_portにfalseが設定されている場合" do
      let(:unfold_sv_interface_port) { [false, nil, 'false', 'nil', 'off', 'no'].shuffle.first }

      it "rggen_axi4lite_ifを入出力ポートに持つ" do
        expect(rtl).to have_interface_port(:register_block, :axi4lite_if, type: :rggen_axi4lite_if, modport: :slave)
      end

      it "AXI4-Lite用のホストIFモジュールをインスタンスするコードを生成する" do
        expected_code =<<'CODE'
rggen_host_if_axi4lite #(
  .LOCAL_ADDRESS_WIDTH  (8),
  .DATA_WIDTH           (32),
  .TOTAL_REGISTERS      (14),
  .ACCESS_PRIORITY      (ACCESS_PRIORITY)
) u_host_if (
  .clk          (clk),
  .rst_n        (rst_n),
  .axi4lite_if  (axi4lite_if),
  .register_if  (register_if)
);
CODE
        expect(rtl).to generate_code(:register_block, :top_down, expected_code)
      end
    end

    context "unfold_sv_interface_portにtrueが設定されている場合" do
      let(:unfold_sv_interface_port) { [true, 'true', 'on', 'yes'].shuffle.first }

      it "AXI4 Lite用の入出力ポートを持つ" do
        expect(rtl).to have_input(:register_block, :awvalid, name: 'i_awvalid', data_type: :logic, width: 1)
        expect(rtl).to have_output(:register_block, :awready, name: 'o_awready', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :awaddr, name: 'i_awaddr', data_type: :logic, width: local_address_width)
        expect(rtl).to have_input(:register_block, :awprot, name: 'i_awprot', data_type: :logic, width: 3)
        expect(rtl).to have_input(:register_block, :wvalid, name: 'i_wvalid', data_type: :logic, width: 1)
        expect(rtl).to have_output(:register_block, :wready, name: 'o_wready', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :wdata, name: 'i_wdata', data_type: :logic, width: data_width)
        expect(rtl).to have_input(:register_block, :wstrb, name: 'i_wstrb', data_type: :logic, width: data_width / 8)
        expect(rtl).to have_output(:register_block, :bvalid, name: 'o_bvalid', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :bready, name: 'i_bready', data_type: :logic, width: 1)
        expect(rtl).to have_output(:register_block, :bresp, name: 'o_bresp', data_type: :logic, width: 2)
        expect(rtl).to have_input(:register_block, :arvalid, name: 'i_arvalid', data_type: :logic, width: 1)
        expect(rtl).to have_output(:register_block, :arready, name: 'o_arready', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :araddr, name: 'i_araddr', data_type: :logic, width: local_address_width)
        expect(rtl).to have_input(:register_block, :arprot, name: 'i_arprot', data_type: :logic, width: 3)
        expect(rtl).to have_output(:register_block, :rvalid, name: 'o_rvalid', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :rready, name: 'i_rready', data_type: :logic, width: 1)
        expect(rtl).to have_output(:register_block, :rdata, name: 'o_rdata', data_type: :logic, width: data_width)
        expect(rtl).to have_output(:register_block, :rresp, name: 'o_rresp', data_type: :logic, width: 2)
      end

      it "rggen_axi4lite_ifのインスタンスを持つ" do
        expect(rtl). to have_interface(:register_block, :axi4lite_if, type: :rggen_axi4lite_if, name: 'axi4lite_if', parameters: [local_address_width, data_width])
      end

      it "AXI$ Lite用のホストIFモジュールをインスタンスするコード(IF接続含む)を出力する" do
        expected_code =<<'CODE'
assign axi4lite_if.awvalid = i_awvalid;
assign o_awready = axi4lite_if.awready;
assign axi4lite_if.awaddr = i_awaddr;
assign axi4lite_if.awprot = i_awprot;
assign axi4lite_if.wvalid = i_wvalid;
assign o_wready = axi4lite_if.wready;
assign axi4lite_if.wdata = i_wdata;
assign axi4lite_if.wstrb = i_wstrb;
assign o_bvalid = axi4lite_if.bvalid;
assign axi4lite_if.bready = i_bready;
assign o_bresp = axi4lite_if.bresp;
assign axi4lite_if.arvalid = i_arvalid;
assign o_arready = axi4lite_if.arready;
assign axi4lite_if.araddr = i_araddr;
assign axi4lite_if.arprot = i_arprot;
assign o_rvalid = axi4lite_if.rvalid;
assign axi4lite_if.rready = i_rready;
assign o_rdata = axi4lite_if.rdata;
assign o_rresp = axi4lite_if.rresp;
rggen_host_if_axi4lite #(
  .LOCAL_ADDRESS_WIDTH  (8),
  .DATA_WIDTH           (32),
  .TOTAL_REGISTERS      (14),
  .ACCESS_PRIORITY      (ACCESS_PRIORITY)
) u_host_if (
  .clk          (clk),
  .rst_n        (rst_n),
  .axi4lite_if  (axi4lite_if),
  .register_if  (register_if)
);
CODE
        expect(rtl).to generate_code(:register_block, :top_down, expected_code)
      end
    end
  end
end
