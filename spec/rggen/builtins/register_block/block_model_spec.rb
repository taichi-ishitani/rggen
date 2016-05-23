require_relative '../spec_helper'

describe 'register_block/block_model' do
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
    enable :register_block, [:block_model, :constructor, :sub_model_creator, :default_map_creator]

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
      ],
      "block_1" => [
        [nil, nil, "block_1"                                                                                                       ],
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
        [nil, nil         , nil        , nil     , nil                           , nil , "bit_field_3_1", "[15: 0]", "rw", 0  , nil]
      ]
    )
    @ral  = build_ral_factory.create(configuration, register_map).register_blocks
  end

  after(:all) do
    clear_enabled_items
  end

  let(:ral) do
    @ral
  end

  describe "#generate_code" do
    let(:expected_code_0) do
      <<'CODE'
class block_0_block_model#(
  type REGISTER_4 = rggen_ral_block
) extends rggen_ral_block;
  rand register_0_reg_model register_0;
  rand register_1_reg_model register_1[2];
  rand register_2_reg_model register_2[2];
  rand register_3_reg_model register_3[2][4];
  rand REGISTER_4 register_4;
  function new(string name = "block_0");
    super.new(name);
  endfunction
  function void create_sub_models();
    `rggen_ral_create_reg_model(register_0, "register_0", '{}, 8'h00, "RW", 0)
    foreach (register_1[i]) begin
      `rggen_ral_create_reg_model(register_1[i], "register_1", '{i}, 8'h04 + 4 * i, "RO", 0)
    end
    foreach (register_2[i]) begin
      `rggen_ral_create_reg_model(register_2[i], "register_2", '{i}, 8'h0c, "WO", 1)
    end
    foreach (register_3[i, j]) begin
      `rggen_ral_create_reg_model(register_3[i][j], "register_3", '{i, j}, 8'h10, "RW", 1)
    end
    `rggen_ral_create_block_model(register_4, "register_4", 8'h20)
  endfunction
  function uvm_reg_map create_default_map();
    return create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
  endfunction
endclass
CODE
    end

    let(:expected_code_1) do
      <<'CODE'
class block_1_block_model extends rggen_ral_block;
  rand register_0_reg_model register_0;
  rand register_1_reg_model register_1[2];
  rand register_2_reg_model register_2[2];
  rand register_3_reg_model register_3[2][4];
  function new(string name = "block_1");
    super.new(name);
  endfunction
  function void create_sub_models();
    `rggen_ral_create_reg_model(register_0, "register_0", '{}, 8'h00, "RW", 0)
    foreach (register_1[i]) begin
      `rggen_ral_create_reg_model(register_1[i], "register_1", '{i}, 8'h04 + 4 * i, "RO", 0)
    end
    foreach (register_2[i]) begin
      `rggen_ral_create_reg_model(register_2[i], "register_2", '{i}, 8'h0c, "WO", 1)
    end
    foreach (register_3[i, j]) begin
      `rggen_ral_create_reg_model(register_3[i][j], "register_3", '{i, j}, 8'h10, "RW", 1)
    end
  endfunction
  function uvm_reg_map create_default_map();
    return create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
  endfunction
endclass
CODE
    end

    it "レジスタブロックモデルの定義を生成する" do
      expect(ral[0]).to generate_code(:package_item, :top_down, expected_code_0)
      expect(ral[1]).to generate_code(:package_item, :top_down, expected_code_1)
    end
  end
end
