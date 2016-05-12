require_relative '../spec_helper'

describe "register/read_data" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, :data_width
    enable :global, :address_width
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:clock_reset, :host_if, :response_mux]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :shadow, :external, :accessibility]
    enable :register, [:index, :read_data]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field, :type, [:rw, :ro, :wo, :reserved]

    configuration = create_configuration({})
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                                                                              ],
        [nil, nil         , 256                                                                                                    ],
        [nil, nil         , nil                                                                                                    ],
        [nil, nil         , nil                                                                                                    ],
        [nil, "register_0", "0x00"     , nil     , nil                           , nil , "bit_field_0_0", "[31:16]", "rw"      , 0  ],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_0_1", "[15: 0]", "ro"      , nil],
        [nil, "register_1", "0x04"     , nil     , nil                           , nil , "bit_field_1_0", "[ 7: 0]", "rw"      , 0  ],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_1_1", "[23:16]", "ro"      , nil],
        [nil, "register_2", "0x08"     , nil     , nil                           , nil , "bit_field_2_0", "[31:24]", "reserved", nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_2_1", "[23:16]", "ro"      , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_2_2", "[15: 8]", "wo"      , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_2_3", "[ 7: 0]", "rw"      , 0  ],
        [nil, "register_3", "0x0C"     , nil     , nil                           , nil , "bit_field_3_0", "[ 7: 0]", "reserved", nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_3_1", "[15: 8]", "ro"      , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_3_2", "[23:16]", "wo"      , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_3_3", "[31:24]", "rw"      , 0  ],
        [nil, "register_4", "0x10"     , nil     , nil                           , nil , "bit_field_4_0", "[31:24]", "ro"      , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_4_1", "[23:20]", "reserved", nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_4_2", "[11: 8]", "wo"      , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_4_3", "[ 7: 0]", "rw"      , 0  ],
        [nil, "register_5", "0x14-0x1B", "[2]"   , nil                           , nil , "bit_field_5_0", "[31:16]", "rw"      , 0  ],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_5_1", "[15:0]" , "ro"      , nil],
        [nil, "regsiter_6", "0x1C"     , "[2, 4]", "bit_field_0_0, bit_field_0_1", nil , "bit_field_6_0", "[31:16]", "ro"      , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_6_1", "[15:0]" , "rw"      , 0  ],
        [nil, "register_7", "0x20"     , nil     , nil                           , nil , "bit_field_7_0", "[31:16]", "wo"      , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_7_1", "[15: 0]", "reserved", nil],
        [nil, "register_8", "0x24-0x2F", nil     , nil                           , true, nil            , nil      , nil       , nil]
      ]
    )
    @rtl  = build_rtl_factory.create(configuration, register_map).registers
  end

  after(:all) do
    clear_enabled_items
  end

  let(:rtl) do
    @rtl
  end

  describe "#generate_code" do
    context "レジスタ内に読み出し可能なビットフィールドを含む場合" do
      it "読み出し可能なビットフィールドを集めて、読み出しデータを作成するコードを生成する" do
        expect(rtl[0]).to generate_code(:module_item, :top_down, "assign register_read_data[0] = {bit_field_0_0_value, bit_field_0_1_value};\n"              )
        expect(rtl[1]).to generate_code(:module_item, :top_down, "assign register_read_data[1] = {8'h00, bit_field_1_1_value, 8'h00, bit_field_1_0_value};\n")
        expect(rtl[2]).to generate_code(:module_item, :top_down, "assign register_read_data[2] = {8'h00, bit_field_2_1_value, 8'h00, bit_field_2_3_value};\n")
        expect(rtl[3]).to generate_code(:module_item, :top_down, "assign register_read_data[3] = {bit_field_3_3_value, 8'h00, bit_field_3_1_value, 8'h00};\n")
        expect(rtl[4]).to generate_code(:module_item, :top_down, "assign register_read_data[4] = {bit_field_4_0_value, 16'h0000, bit_field_4_3_value};\n"    )
        expect(rtl[5]).to generate_code(:module_item, :top_down, "assign register_read_data[5+g_i] = {bit_field_5_0_value[g_i], bit_field_5_1_value[g_i]};\n")
        expect(rtl[6]).to generate_code(:module_item, :top_down, "assign register_read_data[7+4*g_i+g_j] = {bit_field_6_0_value[g_i][g_j], bit_field_6_1_value[g_i][g_j]};\n")
      end
    end

    context "レジスタ内に読み出し可能なビットフィールドが無い場合" do
      it "ダミーの読み出しデータとして0を返すコードを生成する" do
        expect(rtl[7]).to generate_code(:module_item, :top_down, "assign register_read_data[15] = 32'h00000000;\n")
      end
    end

    context "外部レジスタの場合" do
      it "コードを生成しない" do
        expect(rtl[8]).not_to generate_code(:module_item, :top_down)
      end
    end
  end
end
