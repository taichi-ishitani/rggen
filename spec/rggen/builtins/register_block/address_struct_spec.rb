require_relative '../spec_helper'

describe "register_block/address_struct" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'c header common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    @configuration  = create_configuration
  end

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, [:external, :indirect]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :wo, :reserved]
  end

  before(:all) do
    enable :register_block, :address_struct
    @c_header_factory = build_c_header_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    @configuration
  end

  let(:c_header) do
    @c_header_factory.create(configuration, register_map).register_blocks
  end

  describe "#generate_code" do
    describe "基本機能" do
      let(:register_map) do
        create_register_map(
          configuration,
          "block_0" => [
            [nil, nil, "block_0"                                                                                                           ],
            [nil, nil, 256                                                                                                                 ],
            [                                                                                                                              ],
            [                                                                                                                              ],
            [nil, "register_0", "0x00"       , nil     , nil                                     , "bit_field_0_0", "[31:0]", :rw, 0  , nil]
          ],
          "block_1" => [
            [nil, nil, "block_1"                                                                                                           ],
            [nil, nil, 256                                                                                                                 ],
            [                                                                                                                              ],
            [                                                                                                                              ],
            [nil, "register_0", "0x00"       , nil     , nil                                     , "bit_field_0_0", "[31:0]", :rw, 0  , nil],
            [nil, "register_1", "0x04"       , nil     , nil                                     , "bit_field_1_0", "[31:0]", :ro, 0  , nil],
            [nil, "register_2", "0x08"       , nil     , nil                                     , "bit_field_2_0", "[31:0]", :wo, 0  , nil],
            [nil, "register_3", "0x0C"       , "[2, 2]", "indirect: bit_field_0_0, bit_field_1_0", "bit_field_3_0", "[31:0]", :rw, 0  , nil],
            [nil, "register_4", "0x10"       , "[1]"   , nil                                     , "bit_field_4_0", "[31:0]", :wo, 0  , nil],
            [nil, "register_5", "0x14 - 0x1F", "[3]"   , nil                                     , "bit_field_5_0", "[31:0]", :wo, 0  , nil],
            [nil, "register_6", "0x20 - 0x2F", nil     , "external"                              , nil            , nil     ,nil , nil, nil]
          ]
        )
      end

      let(:expected_code_0) do
        <<'CODE'
typedef struct {
  rggen_uint32 register_0;
} s_block_0_address_struct;
CODE
      end

      let(:expected_code_1) do
        <<'CODE'
typedef struct {
  rggen_uint32 register_0;
  rggen_uint32 register_1;
  rggen_uint32 register_2;
  rggen_uint32 register_3;
  rggen_uint32 register_4[1];
  rggen_uint32 register_5[3];
  RGGEN_EXTERNAL_REGISTERS(16, REGISTER_6) register_6;
} s_block_1_address_struct;
CODE
      end

      it "アドレス構造体の定義を返す" do
        expect(c_header[0]).to generate_code :c_header_item, :top_down, expected_code_0
        expect(c_header[1]).to generate_code :c_header_item, :top_down, expected_code_1
      end
    end

    context "reserved領域を含む場合" do
      let(:register_map) do
        create_register_map(
          configuration,
          "block_0" => [
            [nil, nil, "block_0"                                                               ],
            [nil, nil, 256                                                                     ],
            [                                                                                  ],
            [                                                                                  ],
            [nil, "register_0", "0x0", nil, nil, "bit_field_0_0", "[31:0]", :reserved, nil, nil],
            [nil, "register_1", "0x4", nil, nil, "bit_field_1_0", "[31:0]", :rw      , 0  , nil]
          ],
          "block_1" => [
            [nil, nil, "block_1"                                                               ],
            [nil, nil, 256                                                                     ],
            [                                                                                  ],
            [                                                                                  ],
            [nil, "register_0", "0x4", nil, nil, "bit_field_0_0", "[31:0]", :reserved, nil, nil],
            [nil, "register_1", "0x8", nil, nil, "bit_field_1_0", "[31:0]", :rw      , 0  , nil]
          ],
          "block_2" => [
            [nil, nil, "block_2"                                                               ],
            [nil, nil, 256                                                                     ],
            [                                                                                  ],
            [                                                                                  ],
            [nil, "register_0", "0x0", nil, nil, "bit_field_0_0", "[31:0]", :rw      , 0  , nil],
            [nil, "register_1", "0x4", nil, nil, "bit_field_1_0", "[31:0]", :reserved, nil, nil],
            [nil, "register_2", "0x8", nil, nil, "bit_field_2_0", "[31:0]", :rw      , 0  , nil]
          ],
          "block_3" => [
            [nil, nil, "block_3"                                                               ],
            [nil, nil, 256                                                                     ],
            [                                                                                  ],
            [                                                                                  ],
            [nil, "register_0", "0x0", nil, nil, "bit_field_0_0", "[31:0]", :rw      , 0  , nil],
            [nil, "register_1", "0x8", nil, nil, "bit_field_1_0", "[31:0]", :reserved, nil, nil],
            [nil, "register_2", "0xC", nil, nil, "bit_field_2_0", "[31:0]", :rw      , 0  , nil]
          ],
          "block_4" => [
            [nil, nil, "block_4"                                                               ],
            [nil, nil, 256                                                                     ],
            [                                                                                  ],
            [                                                                                  ],
            [nil, "register_0", "0x0", nil, nil, "bit_field_0_0", "[31:0]", :rw      , 0  , nil],
            [nil, "register_1", "0x4", nil, nil, "bit_field_1_0", "[31:0]", :reserved, nil, nil]
          ],
          "block_5" => [
            [nil, nil, "block_5"                                                               ],
            [nil, nil, 256                                                                     ],
            [                                                                                  ],
            [                                                                                  ],
            [nil, "register_0", "0x0", nil, nil, "bit_field_0_0", "[31:0]", :rw      , 0  , nil],
            [nil, "register_1", "0x8", nil, nil, "bit_field_1_0", "[31:0]", :reserved, nil, nil]
          ],
          "block_6" => [
            [nil, nil, "block_6"                                                              ],
            [nil, nil, 256                                                                    ],
            [                                                                                 ],
            [                                                                                 ],
            [nil, "register_3", "0x34", nil, nil, "bit_field_3_0", "[31:0]", :reserved, 0, nil],
            [nil, "register_2", "0x20", nil, nil, "bit_field_2_0", "[31:0]", :rw      , 0, nil],
            [nil, "register_1", "0x10", nil, nil, "bit_field_1_0", "[31:0]", :rw      , 0, nil],
            [nil, "register_0", "0x04", nil, nil, "bit_field_0_0", "[31:0]", :rw      , 0, nil]
          ]
        )
      end

      let(:expected_code_0) do
        <<'CODE'
typedef struct {
  rggen_uint32 __dummy_0[1];
  rggen_uint32 register_1;
} s_block_0_address_struct;
CODE
      end

      let(:expected_code_1) do
        <<'CODE'
typedef struct {
  rggen_uint32 __dummy_0[2];
  rggen_uint32 register_1;
} s_block_1_address_struct;
CODE
      end

      let(:expected_code_2) do
        <<'CODE'
typedef struct {
  rggen_uint32 register_0;
  rggen_uint32 __dummy_0[1];
  rggen_uint32 register_2;
} s_block_2_address_struct;
CODE
      end

      let(:expected_code_3) do
        <<'CODE'
typedef struct {
  rggen_uint32 register_0;
  rggen_uint32 __dummy_0[2];
  rggen_uint32 register_2;
} s_block_3_address_struct;
CODE
      end

      let(:expected_code_4) do
        <<'CODE'
typedef struct {
  rggen_uint32 register_0;
} s_block_4_address_struct;
CODE
      end

      let(:expected_code_5) do
        <<'CODE'
typedef struct {
  rggen_uint32 register_0;
} s_block_5_address_struct;
CODE
      end

      let(:expected_code_6) do
        <<'CODE'
typedef struct {
  rggen_uint32 __dummy_0[1];
  rggen_uint32 register_0;
  rggen_uint32 __dummy_1[2];
  rggen_uint32 register_1;
  rggen_uint32 __dummy_2[3];
  rggen_uint32 register_2;
} s_block_6_address_struct;
CODE
      end

      specify "リザーブド領域は__dummy_nで埋める" do
        expect(c_header[0]).to generate_code :c_header_item, :top_down, expected_code_0
        expect(c_header[1]).to generate_code :c_header_item, :top_down, expected_code_1
        expect(c_header[2]).to generate_code :c_header_item, :top_down, expected_code_2
        expect(c_header[3]).to generate_code :c_header_item, :top_down, expected_code_3
        expect(c_header[4]).to generate_code :c_header_item, :top_down, expected_code_4
        expect(c_header[5]).to generate_code :c_header_item, :top_down, expected_code_5
        expect(c_header[6]).to generate_code :c_header_item, :top_down, expected_code_6
      end
    end
  end
end
