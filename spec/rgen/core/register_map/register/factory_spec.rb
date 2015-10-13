require_relative  '../spec_helper'

module RGen::RegisterMap::Register
  describe Factory do
    include_context 'bit_field sample factories'
    include_context 'register sample factories'

    let(:configuration) do
      get_component_class(:configuration, 0).new
    end

    let(:register_block) do
      get_component_class(:register_map, 1).new
    end

    let(:rows) do
      [
        create_cells([:foo, :bar, :foo_0, :bar_0], row: 0),
        create_cells([nil , nil , :foo_1, :bar_1], row: 1)
      ]
    end

    describe "#create" do
      let(:register) do
        register_factory.create(register_block, configuration, rows)
      end

      it "登録されたアイテムオブジェクトを持つレジスタオブジェクトを生成する" do
        expect(register).to match_register(register_block, foo: :foo, bar: :bar)
      end

      specify "生成されたレジスタオブジェクトは適切な値を持つビットフィールドオブジェクトを持つ" do
        expect(register.bit_fields).to match([
          match_bit_field(register, foo: :foo_0, bar: :bar_0),
          match_bit_field(register, foo: :foo_1, bar: :bar_1)
        ])
      end
    end
  end
end
