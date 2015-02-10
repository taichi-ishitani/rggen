require_relative  '../spec_helper'

module RGen::RegisterMap::BitField
  describe Factory do
    include_context 'bit_field sample factories'

    let(:configuration) do
      RGen::Configuration::Configuration.new
    end

    let(:register) do
      RGen::RegisterMap::Register::Register.new
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
