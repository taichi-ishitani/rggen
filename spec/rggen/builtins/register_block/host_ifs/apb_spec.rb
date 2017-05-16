require_relative '../../spec_helper'

describe "register_block/apb" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, [:address_width, :data_width]
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
    before(:all) do
      configuration = create_configuration(host_if: :apb, data_width: 32, address_width: 16)
      register_map  = create_register_map(
        configuration,
        "block_0" => [
          [nil, nil         , "block_0"                                                                                                 ],
          [nil, nil         , 252                                                                                                       ],
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
      @rtl  = build_rtl_factory.create(configuration, register_map).register_blocks[0]
    end

    let(:rtl) do
      @rtl
    end

    let(:data_width) do
      32
    end

    let(:host_address_width) do
      16
    end

    it "rggen_apb_ifを入出力ポートに持つ" do
      expect(rtl).to have_interface_port(:register_block, :apb_if, type: :rggen_apb_if, modport: :slave)
    end

    describe "#generate_code" do
      let(:expected_code) do
        <<'CODE'
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
      end

      it "APB用のホストIFモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:register_block, :top_down, expected_code)
      end
    end
  end
end
