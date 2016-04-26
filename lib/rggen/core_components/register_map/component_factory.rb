module RgGen
  module RegisterMap
    class ComponentFactory < InputBase::ComponentFactory
      def create_component(parent, configuration, _)
        @target_component.new(parent, configuration)
      end
    end
  end
end
