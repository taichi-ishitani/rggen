module RegisterGenerator::Base
  class ComponentFactory
    def initialize
      @item_factories = {}
    end

    def create(*args)
      parent    = (@root_factory) ? nil : args.pop
      sources   = args

      component = create_component(parent, *sources)

      unless @item_factories.empty?
        create_items(component, *sources)
      end

      if @child_factory
        create_children(component, *sources)
      end

      component
    end

    def register_component(component)
      @target_component = component
    end

    def register_item_factory(name, item_factory)
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

    def create_child(component, *sources)
      @child_factory.create(component, *sources)
    end
  end
end
