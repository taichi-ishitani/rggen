require_relative '../spec_helper'

describe 'register/sub_block_model' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'ral common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register , [:name, :offset_address, :array, :shadow, :external, :accessibility]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :wo]
    enable :register , :sub_block_model

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         ,"block_0"                                                               ],
        [nil, nil         , 256                                                                    ],
        [                                                                                          ],
        [                                                                                          ],
        [nil, "register_0", "0x00"     , nil, nil, nil , "bit_field_0_0", "[31:0 ]", "rw", 0  , nil],
        [nil, "register_1", "0x10-0x1F", nil, nil, true, nil            , nil      , nil , nil, nil],
        [nil, "register_2", "0x20-0x3F", nil, nil, true, nil            , nil      , nil , nil, nil]
      ]
    )
    @ral  = build_ral_factory.create(configuration, register_map).registers
  end

  after(:all) do
    clear_enabled_items
  end

  context "レジスタが内部レジスタの場合" do
    let(:register) do
      @ral[0]
    end

    it "有効なアイテムではない" do
      expect(register).not_to have_item :register, :ral, :sub_block_model
    end
  end

  context "レジスタが外部レジスタの場合" do
    let(:registers) do
      @ral[1..2]
    end

    it "有効なアイテムである" do
      expect(registers).to all(have_item(:register, :ral, :sub_block_model))
    end

    describe "#build" do
      it "所有者コンポーネントに自身の型のパラメータ宣言を追加する" do
        expect(registers[0]).to have_parameter(:block_model, :model_type, data_type: :type, name: :REGISTER_1, default: :rggen_ral_block)
        expect(registers[1]).to have_parameter(:block_model, :model_type, data_type: :type, name: :REGISTER_2, default: :rggen_ral_block)
      end

      it "所有者コンポーネントに自身の宣言を追加する" do
        expect(registers[0]).to have_variable(:block_model, :sub_block_model, data_type: :REGISTER_1, name: :register_1, random: true)
        expect(registers[1]).to have_variable(:block_model, :sub_block_model, data_type: :REGISTER_2, name: :register_2, random: true)
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

      let(:expected_code_0) do
        <<'CODE'
`rggen_ral_create_block_model(register_1, "register_1", 8'h10)
CODE
      end

      let(:expected_code_1) do
        <<'CODE'
`rggen_ral_create_block_model(register_2, "register_2", 8'h20)
CODE
      end

      let(:expected_code) do
        [expected_code_0, expected_code_1].join
      end

      it "サブブロックモデル生成コードを生成する" do
        expect(code.to_s).to eq expected_code
      end
    end
  end
end
