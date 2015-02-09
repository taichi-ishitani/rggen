class RGen::Base::ComponentFactory
  def create(*args)
    parent    = (@root_factory) ? nil : args.pop
    sources   = args

    component = create_component(parent, *sources)

    create_items(component, *sources) if @item_factories
    create_children(component, *sources) if @child_factory

    component
  end

  def register_component(component)
    @target_component = component
  end

  def register_item_factory(name, item_factory)
    @item_factories ||= {}
    @item_factories[name] = item_factory
  end

  def register_child_factory(child_factory)
    @child_factory  = child_factory
  end

  def root_factory
    @root_factory = true
  end

  def create_component(parent, *sources)
    @target_component.new(parent)
  end
  private :create_component

  def create_item(item_factory, component, *sources)
    item  = item_factory.create(component, *sources)
    component.append_item(item)
  end
  private :create_item

  def create_child(component, *sources)
    child = @child_factory.create(component, *sources)
    component.append_child(child)
  end
  private :create_child
end
