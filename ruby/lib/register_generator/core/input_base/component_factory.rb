module RegisterGenerator::InputBase
  class ComponentFactory < Base::ComponentFactory
    def create(*args)
      component = super(*args)
      component.validate  if @root_factory
      component
    end
  end
end
