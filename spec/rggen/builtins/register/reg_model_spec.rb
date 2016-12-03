require_relative '../spec_helper'

describe 'register/reg_model' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register , [:name, :offset_address, :array, :type]
    enable :register , :type, [:external, :indirect]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :w0c, :w1c, :w0s, :w1s, :wo]
    enable :register , [:reg_model, :constructor, :field_model_creator, :indirect_index_configurator]
    enable :bit_field, :field_model

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                                                                                                                      ],
        [nil, nil         , 256                                                                                                                                           ],
        [                                                                                                                                                                 ],
        [                                                                                                                                                                 ],
        [nil, "register_0", "0x00"     , nil     , nil                                                                       , "bit_field_0_0", "[31:24]", "rw" , 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_0_1", "[23:16]", "rw" , 1  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_0_2", "[15: 8]", "ro" , 2  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_0_3", "[ 7: 0]", "ro" , nil, nil],
        [nil, "register_1", "0x04-0x0B", "[2]"   , nil                                                                       , "bit_field_1_0", "[31:16]", "rw" , 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_1_1", "[15: 0]", "rw" , 0  , nil],
        [nil, "register_2", "0x10"     , "[4]"   , "indirect: bit_field_0_0"                                                 , "bit_field_2_0", "[15: 8]", "ro" , 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_2_1", "[ 7: 0]", "ro" , 0  , nil],
        [nil, "register_3", "0x14"     , "[2, 4]", "indirect: bit_field_0_0, bit_field_0_1:1, bit_field_0_2, bit_field_0_3:3", "bit_field_3_0", "[ 7: 4]", "wo" , 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_3_1", "[ 3: 0]", "wo" , 0  , nil],
        [nil, "register_4", "0x18"     , nil     , nil                                                                       , "bit_field_4_0", "[8]"    , "w0c", 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_4_1", "[0]"    , "w1c", 0  , nil],
        [nil, "register_5", "0x1C"     , nil     , nil                                                                       , "bit_field_5_0", "[8]"    , "w0s", 0  , nil],
        [nil, nil         , nil        , nil     , nil                                                                       , "bit_field_5_1", "[0]"    , "w1s", 0  , nil],
        [nil, "register_6", "0x20"     , nil     , :external                                                                 , nil            , nil      , nil  , nil, nil]
      ]
    )
    @ral  = build_ral_factory.create(configuration, register_map)
  end

  after(:all) do
    clear_enabled_items
  end

  context "レジスタが内部レジスタの場合" do
    let(:registers) do
      @ral.registers[0..5]
    end

    it "有効なアイテムである" do
      expect(registers).to all(have_item(:register, :ral, :reg_model))
    end

    describe "#build" do
      it "所有者コンポーネントに自身の宣言を追加する" do
        expect(registers[0]).to have_variable(:block_model, :reg_model, data_type: 'register_0_reg_model', name: 'register_0', random: true)
        expect(registers[1]).to have_variable(:block_model, :reg_model, data_type: 'register_1_reg_model', name: 'register_1', random: true, dimensions: [2   ])
        expect(registers[2]).to have_variable(:block_model, :reg_model, data_type: 'register_2_reg_model', name: 'register_2', random: true, dimensions: [4   ])
        expect(registers[3]).to have_variable(:block_model, :reg_model, data_type: 'register_3_reg_model', name: 'register_3', random: true, dimensions: [2, 4])
        expect(registers[4]).to have_variable(:block_model, :reg_model, data_type: 'register_4_reg_model', name: 'register_4', random: true)
        expect(registers[5]).to have_variable(:block_model, :reg_model, data_type: 'register_5_reg_model', name: 'register_5', random: true)
      end
    end

    describe "#model_creation" do
      before do
        registers.each do |register|
          register.model_creation(code)
        end
      end

      let(:code) do
        RgGen::CodeUtility::CodeBlock.new
      end

      let(:expected_code) do
        [expected_code_0, expected_code_1, expected_code_2, expected_code_3, expected_code_4, expected_code_5].join
      end

      let(:expected_code_0) do
        <<'CODE'
`rggen_ral_create_reg_model(register_0, "register_0", '{}, 8'h00, "RW", 0, "")
CODE
      end

      let(:expected_code_1) do
        <<'CODE'
foreach (register_1[i]) begin
  `rggen_ral_create_reg_model(register_1[i], $sformatf("register_1[%0d]", i), '{i}, 8'h04 + 4 * i, "RW", 0, $sformatf("g_register_1.g[%0d]", i))
end
CODE
      end

      let(:expected_code_2) do
        <<'CODE'
foreach (register_2[i]) begin
  `rggen_ral_create_reg_model(register_2[i], $sformatf("register_2[%0d]", i), '{i}, 8'h10, "RO", 1, $sformatf("g_register_2.g[%0d]", i))
end
CODE
      end

      let(:expected_code_3) do
        <<'CODE'
foreach (register_3[i, j]) begin
  `rggen_ral_create_reg_model(register_3[i][j], $sformatf("register_3[%0d][%0d]", i, j), '{i, j}, 8'h14, "WO", 1, $sformatf("g_register_3.g[%0d].g[%0d]", i, j))
end
CODE
      end

      let(:expected_code_4) do
        <<'CODE'
`rggen_ral_create_reg_model(register_4, "register_4", '{}, 8'h18, "RW", 0, "")
CODE
      end

      let(:expected_code_5) do
        <<'CODE'
`rggen_ral_create_reg_model(register_5, "register_5", '{}, 8'h1c, "RW", 0, "")
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
    `rggen_ral_create_field_model(bit_field_0_0, "bit_field_0_0", 8, 24, "RW", 0, 8'h00, 1, "u_bit_field_0_0.value")
    `rggen_ral_create_field_model(bit_field_0_1, "bit_field_0_1", 8, 16, "RW", 0, 8'h01, 1, "u_bit_field_0_1.value")
    `rggen_ral_create_field_model(bit_field_0_2, "bit_field_0_2", 8, 8, "RO", 0, 8'h02, 1, "u_bit_field_0_2.i_value")
    `rggen_ral_create_field_model(bit_field_0_3, "bit_field_0_3", 8, 0, "RO", 0, 8'h00, 0, "u_bit_field_0_3.i_value")
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
    `rggen_ral_create_field_model(bit_field_1_0, "bit_field_1_0", 16, 16, "RW", 0, 16'h0000, 1, "u_bit_field_1_0.value")
    `rggen_ral_create_field_model(bit_field_1_1, "bit_field_1_1", 16, 0, "RW", 0, 16'h0000, 1, "u_bit_field_1_1.value")
  endfunction
endclass
CODE
      end

      let(:expected_code_2) do
        <<'CODE'
class register_2_reg_model extends rggen_ral_indirect_reg;
  rand rggen_ral_field bit_field_2_0;
  rand rggen_ral_field bit_field_2_1;
  function new(string name = "register_2");
    super.new(name, 16, 0);
  endfunction
  function void create_fields();
    `rggen_ral_create_field_model(bit_field_2_0, "bit_field_2_0", 8, 8, "RO", 0, 8'h00, 1, "u_bit_field_2_0.i_value")
    `rggen_ral_create_field_model(bit_field_2_1, "bit_field_2_1", 8, 0, "RO", 0, 8'h00, 1, "u_bit_field_2_1.i_value")
  endfunction
  function void configure_indirect_indexes();
    set_indirect_index("register_0", "bit_field_0_0", indexes[0]);
  endfunction
endclass
CODE
      end

      let(:expected_code_3) do
        <<'CODE'
class register_3_reg_model extends rggen_ral_indirect_reg;
  rand rggen_ral_field bit_field_3_0;
  rand rggen_ral_field bit_field_3_1;
  function new(string name = "register_3");
    super.new(name, 8, 0);
  endfunction
  function void create_fields();
    `rggen_ral_create_field_model(bit_field_3_0, "bit_field_3_0", 4, 4, "WO", 0, 4'h0, 1, "u_bit_field_3_0.value")
    `rggen_ral_create_field_model(bit_field_3_1, "bit_field_3_1", 4, 0, "WO", 0, 4'h0, 1, "u_bit_field_3_1.value")
  endfunction
  function void configure_indirect_indexes();
    set_indirect_index("register_0", "bit_field_0_0", indexes[0]);
    set_indirect_index("register_0", "bit_field_0_1", 1);
    set_indirect_index("register_0", "bit_field_0_2", indexes[1]);
    set_indirect_index("register_0", "bit_field_0_3", 3);
  endfunction
endclass
CODE
      end

      let(:expected_code_4) do
        <<'CODE'
class register_4_reg_model extends rggen_ral_reg;
  rand rggen_ral_field bit_field_4_0;
  rand rggen_ral_field bit_field_4_1;
  function new(string name = "register_4");
    super.new(name, 16, 0);
  endfunction
  function void create_fields();
    `rggen_ral_create_field_model(bit_field_4_0, "bit_field_4_0", 1, 8, "W0C", 0, 1'h0, 1, "u_bit_field_4_0.value")
    `rggen_ral_create_field_model(bit_field_4_1, "bit_field_4_1", 1, 0, "W1C", 0, 1'h0, 1, "u_bit_field_4_1.value")
  endfunction
endclass
CODE
      end

      let(:expected_code_5) do
        <<'CODE'
class register_5_reg_model extends rggen_ral_reg;
  rand rggen_ral_field bit_field_5_0;
  rand rggen_ral_field bit_field_5_1;
  function new(string name = "register_5");
    super.new(name, 16, 0);
  endfunction
  function void create_fields();
    `rggen_ral_create_field_model(bit_field_5_0, "bit_field_5_0", 1, 8, "W0S", 0, 1'h0, 1, "u_bit_field_5_0.value")
    `rggen_ral_create_field_model(bit_field_5_1, "bit_field_5_1", 1, 0, "W1S", 0, 1'h0, 1, "u_bit_field_5_1.value")
  endfunction
endclass
CODE
      end

      it "レジスタモデルの定義を生成する" do
        expect(registers[0]).to generate_code(:package_item, :top_down, expected_code_0)
        expect(registers[1]).to generate_code(:package_item, :top_down, expected_code_1)
        expect(registers[2]).to generate_code(:package_item, :top_down, expected_code_2)
        expect(registers[3]).to generate_code(:package_item, :top_down, expected_code_3)
        expect(registers[4]).to generate_code(:package_item, :top_down, expected_code_4)
      end
    end
  end

  context "レジスタが外部レジスタの場合" do
    let(:register) do
      @ral.registers[6]
    end

    it "有効なアイテムではない" do
      expect(register).not_to have_item :register, :ral, :reg_model
    end
  end
end
