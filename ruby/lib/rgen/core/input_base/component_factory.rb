class RGen::InputBase::ComponentFactory < RGen::Base::ComponentFactory
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

  def register_loader(loader)
    loaders << loader
  end

  def loaders
    @loaders  ||= []
  end
  private :loaders

  def load(file)
    load_file(file)
  end
  private :load

  def load_file(file)
    loader  = find_loader(file)
    loader.load_file(file) if loader
  end
  private :load_file

  def find_loader(file)
    loader  = loaders.find {|l| l.acceptable?(file)}
    if loader
      loader.new
    else
      raise RGen::LoadError, "unsupported file type: #{File.extname(file)}"
    end
  end
  private :find_loader
end
