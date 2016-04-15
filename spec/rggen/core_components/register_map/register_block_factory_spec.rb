require_relative  'spec_helper'

module RgGen::RegisterMap
  describe RegisterBlockFactory do
    include_context 'bit_field sample factories'
    include_context 'register sample factories'
    include_context 'register_block sample factories'

    let(:configuration) do
      get_component_class(:configuration, 0).new(nil)
    end

    let(:register_map) do
      get_component_class(:register_map, 0).new(nil)
    end

    let(:sheet) do
      create_sheet([
        [nil, "foo" , :foo  , nil     , nil     ],
        [nil, "bar" , :bar  , nil     , nil     ],
        [nil, nil   , nil   , nil     , nil     ],
        [nil, "foo" , "bar" , "foo"   , "bar"   ],
        [nil, :foo_0, :bar_0, :foo_0_0, :bar_0_0],
        [nil, nil   , nil   , :foo_0_1, :bar_0_1],
        [nil, :foo_1, :bar_1, :foo_1_0, :bar_1_0],
        [nil, nil   , nil   , nil     , nil     ]
      ])
    end

    describe "#create" do
      let(:register_block) do
        register_block_factory.create(register_map, configuration, sheet)
      end

      it "登録されたアイテムオブジェクトを持つレジスタブロックオブジェクトを生成する" do
        expect(register_block).to match_register_block(register_map, foo: :foo, bar: :bar)
      end

      specify "生成されたレジスタブロックオブジェクトは適切な値を持つレジスタオブジェクトを持つ" do
        expect(register_block.registers).to match([
          match_register(register_block, foo: :foo_0, bar: :bar_0),
          match_register(register_block, foo: :foo_1, bar: :bar_1)
        ])
      end

      specify "配下のレジスタオブジェクトは適切な値を持つビットフィールドオブジェクトを持つ" do
        expect(register_block.registers[0].bit_fields).to match([
          match_bit_field(register_block.registers[0], foo: :foo_0_0, bar: :bar_0_0),
          match_bit_field(register_block.registers[0], foo: :foo_0_1, bar: :bar_0_1),
        ])
        expect(register_block.registers[1].bit_fields).to match([
          match_bit_field(register_block.registers[1], foo: :foo_1_0, bar: :bar_1_0)
        ])
      end
    end
  end
end
