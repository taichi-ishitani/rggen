module RGen::InputBase
  class ComponentFactory < RGen::Base::ComponentFactory
    attr_writer :loaders

    def create(*args)
      if @root_factory
        file    = args.pop
        source  = load(file)
        args    << source

        component = super(*args)
        component.validate
      else
        component = super(*args)
      end
      component
    end

    private

    def create_items(component, *sources)
      create_active_items(component, *sources)
      create_passive_items(component, *sources[0..-2])
    end

    def create_passive_items(component, *sources)
      passive_item_factories.each do |factory|
        create_item(factory, component, *sources)
      end
    end

    def active_item_factories
      @item_factories.each_with_object({}) do |(name, factory), factories|
        factories[name] = factory if factory.active_item_factory?
      end
    end

    def passive_item_factories
      @item_factories.each_value.select(&:passive_item_factory?)
    end

    def load(file)
      load_file(file)
    end

    def load_file(file)
      loader  = find_loader(file)
      loader.load_file(file) if loader
    end

    def find_loader(file)
      loader  = @loaders && @loaders.find {|l| l.acceptable?(file)}
      if loader
        loader.new
      else
        fail RGen::LoadError, "unsupported file type: #{File.ext(file)}"
      end
    end
  end
end
