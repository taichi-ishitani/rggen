require_relative '../../spec_helper'

describe 'register_block/axi4lite' do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, [:address_width, :data_width]
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
    before(:all) do
      configuration = create_configuration(host_if: :axi4lite, data_width: 32, address_width: 16)
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

    it "読み書きの優先度を決めるパラメータを持つ" do
      expect(rtl).to have_parameter(:register_block, :access_priority, name: 'ACCESS_PRIORITY', type: :'rggen_rtl_pkg::rggen_direction', default: :'rggen_rtl_pkg::RGGEN_WRITE')
    end

    it "rggen_axi4lite_ifを入出力ポートに持つ" do
      expect(rtl).to have_interface_port(:register_block, :axi4lite_if, type: :rggen_axi4lite_if, modport: :slave)
    end

    describe "#generate_code" do
      let(:expected_code) do
        <<'CODE'
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
      end

      it "AXI4-Lite用のホストIFモジュールをインスタンスするコードを生成する" do
        expect(rtl).to generate_code(:register_block, :top_down, expected_code)
      end
    end
  end
end
