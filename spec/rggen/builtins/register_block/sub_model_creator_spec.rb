require_relative '../spec_helper'

describe 'register_block/sub_model_creator' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register , [:name, :offset_address, :array, :shadow, :external, :accessibility]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :wo]
    enable :register , [:reg_model, :sub_block_model]
    enable :register_block, :sub_model_creator

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil, "block_0"                                                                                                       ],
        [nil, nil, 256                                                                                                             ],
        [                                                                                                                          ],
        [                                                                                                                          ],
        [nil, "register_0", "0x00"     , nil     , nil                           , nil , "bit_field_0_0", "[31:16]", "rw", 0  , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_0_1", "[15: 0]", "rw", 0  , nil],
        [nil, "register_1", "0x04-0x0B", "[2]"   , nil                           , nil , "bit_field_1_0", "[31:16]", "ro", 0  , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_1_1", "[15: 0]", "ro", 0  , nil],
        [nil, "register_2", "0x0C"     , "[2]"   , "bit_field_0_0"               , nil , "bit_field_2_0", "[31:16]", "wo", 0  , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_2_1", "[15: 0]", "wo", 0  , nil],
        [nil, "register_3", "0x10"     , "[2, 4]", "bit_field_0_0, bit_field_0_1", nil , "bit_field_3_0", "[31:16]", "rw", 0  , nil],
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_3_1", "[15: 0]", "rw", 0  , nil],
        [nil, "register_4", "0x20-0x2F", nil     , nil                           , true, nil            , nil      , nil , nil, nil]
      ]
    )
    @ral  = build_ral_factory.create(configuration, register_map).register_blocks[0]
  end

  after(:all) do
    clear_enabled_items
  end

  let(:ral) do
    @ral
  end

  describe "#generate_code" do
    let(:expected_code) do
      <<'CODE'
function void create_sub_models();
  `rggen_ral_create_reg_model(register_0, "register_0", '{}, 8'h00, "RW", 0, "")
  foreach (register_1[i]) begin
    `rggen_ral_create_reg_model(register_1[i], $sformatf("register_1[%0d]", i), '{i}, 8'h04 + 4 * i, "RO", 0, $sformatf("g_register_1.g[%0d]", i))
  end
  foreach (register_2[i]) begin
    `rggen_ral_create_reg_model(register_2[i], $sformatf("register_2[%0d]", i), '{i}, 8'h0c, "WO", 1, $sformatf("g_register_2.g[%0d]", i))
  end
  foreach (register_3[i, j]) begin
    `rggen_ral_create_reg_model(register_3[i][j], $sformatf("register_3[%0d][%0d]", i, j), '{i, j}, 8'h10, "RW", 1, $sformatf("g_register_3.g[%0d].g[%0d]", i, j))
  end
  `rggen_ral_create_block_model(register_4, "register_4", 8'h20)
endfunction
CODE
    end

    it "レジスタモデルを生成するcreate_registersの定義を生成する" do
      expect(ral).to generate_code(:block_model_item, :top_down, expected_code)
    end
  end
end
