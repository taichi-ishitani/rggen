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

shared_context 'register sample factories' do
  let(:register_factory) do
    f = RGen::RegisterMap::Register::Factory.new
    f.register_component(RGen::RegisterMap::Register::Register)
    f.register_item_factory(:foo, register_foo_factory)
    f.register_item_factory(:bar, register_bar_factory)
    f.register_child_factory(bit_field_factory)
    f
  end

  [:foo, :bar].each do |item_name|
    let("register_#{item_name}_item") do
      Class.new(RGen::RegisterMap::Register::Item) do
        define_field item_name
        build do |cell|
          instance_variable_set("@#{item_name}", cell)
        end
      end
    end

    let("register_#{item_name}_factory") do
      f = RGen::RegisterMap::Register::ItemFactory.new
      f.register(item_name, send("register_#{item_name}_item"))
      f
    end
  end
end

shared_context 'register_block sample factories' do
  let(:register_block_factory) do
    f = RGen::RegisterMap::RegisterBlock::Factory.new
    f.register_component(RGen::RegisterMap::RegisterBlock::RegisterBlock)
    f.register_item_factory(:foo, register_block_foo_factory)
    f.register_item_factory(:bar, register_block_bar_factory)
    f.register_child_factory(register_factory)
    f
  end

  [:foo, :bar].each do |item_name|
    let("register_block_#{item_name}_item") do
      Class.new(RGen::RegisterMap::RegisterBlock::Item) do
        define_field item_name
        build do |cell|
          instance_variable_set("@#{item_name}", cell)
        end
      end
    end

    let("register_block_#{item_name}_factory") do
      f = RGen::RegisterMap::Register::ItemFactory.new
      f.register(item_name, send("register_block_#{item_name}_item"))
      f
    end
  end
end
