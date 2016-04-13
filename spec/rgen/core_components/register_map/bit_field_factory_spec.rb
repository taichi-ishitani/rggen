require_relative  'spec_helper'

module RgGen::RegisterMap
  describe BitFieldFactory do
    include_context 'bit_field sample factories'

    let(:configuration) do
      get_component_class(:configuration, 0).new(nil)
    end

    let(:register) do
      r = get_component_class(:register_map, 2).new(nil)
      r.instance_variable_set(:@level, 2)
      r
    end

    let(:cells) do
      create_cells([0, 1])
    end

    describe "#create" do
      it "登録されたアイテムオブジェクトを持つビットフィールドオブジェクトを生成する" do
        b = bit_field_factory.create(register, configuration, cells)
        expect(b).to match_bit_field(register, foo: 0, bar: 1)
      end
    end
  end
end
