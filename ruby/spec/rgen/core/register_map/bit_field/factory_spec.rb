require_relative  '../spec_helper'

module RGen::RegisterMap::BitField
  describe Factory do
    let(:configuration) do
      RGen::Configuration::Configuration.new
    end

    let(:register) do
      RGen::RegisterMap::Register::Register.new
    end

    let(:factory) do
      f = Factory.new
      f.register_component(BitField)
      f.register_item_factory(:foo, foo_factory)
      f.register_item_factory(:bar, bar_factory)
      f
    end

    [:foo, :bar].each do |item_name|
      let("#{item_name}_item") do
        Class.new(Item) do
          define_field  item_name
          build do |cell|
            instance_variable_set("@#{item_name}", cell)
          end
        end
      end

      let("#{item_name}_factory") do
        f = ItemFactory.new
        f.register(item_name, send("#{item_name}_item"))
        f
      end
    end

    let(:cells) do
      create_cells([0, 1])
    end

    def match_bit_field(parent_register, item_values)
      attributes  = {register: parent_register}
      attributes.merge!(item_values)
      be_kind_of(BitField).and have_attributes(attributes)
    end

    describe "#create" do
      it "登録されたアイテムオブジェクトを持つビットフィールドオブジェクトを生成する" do
        b = factory.create(register, configuration, cells)
        expect(b).to match_bit_field(register, foo: 0, bar: 1)
      end
    end
  end
end