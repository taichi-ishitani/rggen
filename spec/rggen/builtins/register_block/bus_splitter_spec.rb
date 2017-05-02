require_relative '../spec_helper'

describe "register_block/bus_splitter" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, :data_width
    enable :global, :address_width
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:clock_reset, :host_if, :bus_splitter]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, [:indirect, :external]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, :rw

    configuration = create_configuration(host_if: :apb, data_width: 32, address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                                                                                 ],
        [nil, nil         , 256                                                                                                       ],
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

  after(:all) do
    clear_enabled_items
  end

  let(:rtl) do
    @rtl
  end

  let(:address_width) do
    8
  end

  let(:data_width) do
    32
  end

  let(:total_registers) do
    14
  end

  it "レジスタ数分だけのrggen_bus_ifのインスタンスを持つ" do
    expect(rtl).to have_interface(:register_if, type: :rggen_register_if, parameters: [address_width, data_width], dimensions: [total_registers])
  end

  describe "#generate_code" do
    let(:expected_code) do
      <<'CODE'
rggen_bus_splitter #(
  .DATA_WIDTH       (32),
  .TOTAL_REGISTERS  (14)
) u_bus_splitter (
  .clk          (clk),
  .rst_n        (rst_n),
  .bus_if       (bus_if),
  .register_if  (register_if)
);
CODE
    end

    it "応答マルチプレクサモジュールをインスタンスするコードを出力する" do
      expect(rtl).to generate_code(:module_item, :top_down, expected_code)
    end
  end
end

