require_relative '../spec_helper'

describe 'register/reg_model' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register , [:name, :offset_address, :array, :shadow, :accessibility]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :wo]
    enable :register , [:reg_model, :reg_model_constructor, :field_model_creator, :shadow_index_configurator]
    enable :bit_field, :field_model

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                                                                                                           ],
        [nil, nil         , 256                                                                                                                                ],
        [                                                                                                                                                      ],
        [                                                                                                                                                      ],
        [nil, "register_0", "0x00"     , nil     , nil                                                             , "bit_field_0_0", "[31:24]", "rw", 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                             , "bit_field_0_1", "[23:16]", "rw", 1  , nil],
        [nil, nil         , nil        , nil     , nil                                                             , "bit_field_0_2", "[15: 8]", "ro", 2  , nil],
        [nil, nil         , nil        , nil     , nil                                                             , "bit_field_0_3", "[ 7: 0]", "ro", nil, nil],
        [nil, "register_1", "0x04-0x0B", "[2]"   , nil                                                             , "bit_field_1_0", "[31:16]", "rw", 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                             , "bit_field_1_1", "[15: 0]", "rw", 0  , nil],
        [nil, "register_2", "0x10"     , "[4]"   , "bit_field_0_0"                                                 , "bit_field_2_0", "[15: 8]", "ro", 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                             , "bit_field_2_1", "[ 7: 0]", "ro", 0  , nil],
        [nil, "register_3", "0x14"     , "[2, 4]", "bit_field_0_0, bit_field_0_1:1, bit_field_0_2, bit_field_0_3:3", "bit_field_3_0", "[ 7: 4]", "wo", 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                             , "bit_field_3_1", "[ 3: 0]", "wo", 0  , nil]
      ]
    )
    @ral  = build_ral_factory.create(configuration, register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  let(:register_block) do
    @ral.register_blocks[0]
  end

  let(:registers) do
    @ral.registers
  end

  describe "#build" do
    it "親コンポーネントに自身の宣言を追加する" do
      expect(register_block).to have_sub_model('register_0_reg_model', 'register_0')
      expect(register_block).to have_sub_model('register_1_reg_model', 'register_1', dimensions: [2   ])
      expect(register_block).to have_sub_model('register_2_reg_model', 'register_2', dimensions: [4   ])
      expect(register_block).to have_sub_model('register_3_reg_model', 'register_3', dimensions: [2, 4])
    end
  end

  describe "#model_creation" do
    before do
      registers.each do |register|
        register.model_creation(code)
      end
    end

    let(:code) do
      RgGen::OutputBase::CodeBlock.new
    end

    let(:expected_code) do
      [expected_code_0, expected_code_1, expected_code_2, expected_code_3].join
    end

    let(:expected_code_0) do
      <<'CODE'
`rggen_ral_create_reg_model(register_0, "register_0", '{}, 8'h00, "RW", 0)
CODE
    end

    let(:expected_code_1) do
      <<'CODE'
foreach (register_1[i]) begin
  `rggen_ral_create_reg_model(register_1[i], "register_1", '{i}, 8'h04 + 4 * i, "RW", 0)
end
CODE
    end

    let(:expected_code_2) do
      <<'CODE'
foreach (register_2[i]) begin
  `rggen_ral_create_reg_model(register_2[i], "register_2", '{i}, 8'h10, "RO", 1)
end
CODE
    end

    let(:expected_code_3) do
      <<'CODE'
foreach (register_3[i, j]) begin
  `rggen_ral_create_reg_model(register_3[i][j], "register_3", '{i, j}, 8'h14, "WO", 1)
end
CODE
    end

    it "レジスタモデルを生成するコードを生成する" do
      expect(code.to_s).to eq expected_code
    end
  end

  describe "#generate_code" do
    let(:expected_code_0) do
      <<'CODE'
class register_0_reg_model extends rggen_ral_reg;
  rand rggen_ral_field bit_field_0_0;
  rand rggen_ral_field bit_field_0_1;
  rand rggen_ral_field bit_field_0_2;
  rand rggen_ral_field bit_field_0_3;
  function new(string name = "register_0");
    super.new(name, 32, 0);
  endfunction
  function void create_fields();
    `rggen_ral_create_field_model(bit_field_0_0, "bit_field_0_0", 8, 24, "RW", 0, 8'h00, 1)
    `rggen_ral_create_field_model(bit_field_0_1, "bit_field_0_1", 8, 16, "RW", 0, 8'h01, 1)
    `rggen_ral_create_field_model(bit_field_0_2, "bit_field_0_2", 8, 8, "RO", 0, 8'h02, 1)
    `rggen_ral_create_field_model(bit_field_0_3, "bit_field_0_3", 8, 0, "RO", 0, 8'h00, 0)
  endfunction
endclass
CODE
    end

    let(:expected_code_1) do
      <<'CODE'
class register_1_reg_model extends rggen_ral_reg;
  rand rggen_ral_field bit_field_1_0;
  rand rggen_ral_field bit_field_1_1;
  function new(string name = "register_1");
    super.new(name, 32, 0);
  endfunction
  function void create_fields();
    `rggen_ral_create_field_model(bit_field_1_0, "bit_field_1_0", 16, 16, "RW", 0, 16'h0000, 1)
    `rggen_ral_create_field_model(bit_field_1_1, "bit_field_1_1", 16, 0, "RW", 0, 16'h0000, 1)
  endfunction
endclass
CODE
    end

    let(:expected_code_2) do
      <<'CODE'
class register_2_reg_model extends rggen_ral_shadow_reg;
  rand rggen_ral_field bit_field_2_0;
  rand rggen_ral_field bit_field_2_1;
  function new(string name = "register_2");
    super.new(name, 16, 0);
  endfunction
  function void create_fields();
    `rggen_ral_create_field_model(bit_field_2_0, "bit_field_2_0", 8, 8, "RO", 0, 8'h00, 1)
    `rggen_ral_create_field_model(bit_field_2_1, "bit_field_2_1", 8, 0, "RO", 0, 8'h00, 1)
  endfunction
  function void configure_shadow_indexes();
    set_shadow_index("register_0", "bit_field_0_0", indexes[0]);
  endfunction
endclass
CODE
   end

    let(:expected_code_3) do
      <<'CODE'
class register_3_reg_model extends rggen_ral_shadow_reg;
  rand rggen_ral_field bit_field_3_0;
  rand rggen_ral_field bit_field_3_1;
  function new(string name = "register_3");
    super.new(name, 8, 0);
  endfunction
  function void create_fields();
    `rggen_ral_create_field_model(bit_field_3_0, "bit_field_3_0", 4, 4, "WO", 0, 4'h0, 1)
    `rggen_ral_create_field_model(bit_field_3_1, "bit_field_3_1", 4, 0, "WO", 0, 4'h0, 1)
  endfunction
  function void configure_shadow_indexes();
    set_shadow_index("register_0", "bit_field_0_0", indexes[0]);
    set_shadow_index("register_0", "bit_field_0_1", 1);
    set_shadow_index("register_0", "bit_field_0_2", indexes[1]);
    set_shadow_index("register_0", "bit_field_0_3", 3);
  endfunction
endclass
CODE
   end

    it "レジスタモデルの定義を生成する" do
      expect(registers[0]).to generate_code(:package_item, :top_down, expected_code_0)
      expect(registers[1]).to generate_code(:package_item, :top_down, expected_code_1)
      expect(registers[2]).to generate_code(:package_item, :top_down, expected_code_2)
      expect(registers[3]).to generate_code(:package_item, :top_down, expected_code_3)
    end
  end
end
