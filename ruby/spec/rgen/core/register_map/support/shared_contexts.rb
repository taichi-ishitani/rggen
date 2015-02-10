shared_context 'bit_field sample factories' do
  let(:bit_field_factory) do
    f = RGen::RegisterMap::BitField::Factory.new
    f.register_component(RGen::RegisterMap::BitField::BitField)
    f.register_item_factory(:foo, bit_field_foo_factory)
    f.register_item_factory(:bar, bit_field_bar_factory)
    f
  end

  [:foo, :bar].each do |item_name|
    let("bit_field_#{item_name}_item") do
      Class.new(RGen::RegisterMap::BitField::Item) do
        define_field item_name
        build do |cell|
          instance_variable_set("@#{item_name}", cell)
        end
      end
    end

    let("bit_field_#{item_name}_factory") do
      f = RGen::RegisterMap::BitField::ItemFactory.new
      f.register(item_name, send("bit_field_#{item_name}_item"))
      f
    end
  end
end
