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
