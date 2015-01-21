module RegisterGenerator::Base
  class ComponentFactory
    def create(*args)
      parent    = (@root_factory) ? nil : args.pop
      component = create_component(parent, *args)
    end

    def register_component(component)
      @target_component = component
    end

    def root_factory
      @root_factory = true
    end

    def create_component(parent, *args)
      @target_component.new(parent)
    end
  end
end
