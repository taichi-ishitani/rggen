shared_context 'bit_field sample factories' do
  let(:bit_field_factory) do
    f                   = get_component_factory(:register_map, 3).new
    f.target_component  = get_component_class(:register_map, 3)
    f.item_factories    = {foo: bit_field_foo_factory, bar: bit_field_bar_factory}
    f
  end

  [:foo, :bar].each do |item_name|
    let("bit_field_#{item_name}_item") do
      Class.new(get_item_base(:register_map, 3)) do
        field item_name
        build do |cell|
          instance_variable_set("@#{item_name}", cell)
        end
      end
    end

    let("bit_field_#{item_name}_factory") do
      f             = get_item_factory(:register_map, 3).new
      f.target_item = send("bit_field_#{item_name}_item")
      f
    end
  end
end

shared_context 'register sample factories' do
  let(:register_factory) do
    f                   = get_component_factory(:register_map, 2).new
    f.target_component  = get_component_class(:register_map, 2)
    f.item_factories    = {foo: register_foo_factory, bar: register_bar_factory}
    f.child_factory     = bit_field_factory
    f
  end

  [:foo, :bar].each do |item_name|
    let("register_#{item_name}_item") do
      Class.new(get_item_base(:register_map, 2)) do
        field item_name
        build do |cell|
          instance_variable_set("@#{item_name}", cell)
        end
      end
    end

    let("register_#{item_name}_factory") do
      f             = get_item_factory(:register_map, 2).new
      f.target_item = send("register_#{item_name}_item")
      f
    end
  end
end

shared_context 'register_block sample factories' do
  let(:register_block_factory) do
    f                   = get_component_factory(:register_map, 1).new
    f.target_component  = get_component_class(:register_map, 1)
    f.item_factories    = {foo: register_block_foo_factory, bar: register_block_bar_factory}
    f.child_factory     = register_factory
    f
  end

  [:foo, :bar].each do |item_name|
    let("register_block_#{item_name}_item") do
      Class.new(get_item_base(:register_map, 1)) do
        field item_name
        build do |cell|
          instance_variable_set("@#{item_name}", cell)
        end
      end
    end

    let("register_block_#{item_name}_factory") do
      f             = get_item_factory(:register_map, 1).new
      f.target_item = send("register_block_#{item_name}_item")
      f
    end
  end
end

shared_context 'register_map sample factory' do
  let(:register_map_factory) do
    f                   = get_component_factory(:register_map, 0).new
    f.target_component  = get_component_class(:register_map, 0)
    f.child_factory     = register_block_factory
    f.root_factory
    f
  end
end
