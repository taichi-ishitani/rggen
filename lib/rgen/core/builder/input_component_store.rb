module RGen
  module Builder
    class InputComponentStore < ComponentStore
      def initialize(builder, component_name)
        super(builder, component_name)
        @loaders  = []
      end

      attr_setter :loader_base

      def define_loader(type_or_types, &body)
        return unless loader_base
        l                 = Class.new(loader_base, &body)
        l.supported_types = Array(type_or_types)
        @loaders  << l
      end

      def build_factory
        f         = super
        f.loaders = @loaders
        f
      end
    end
  end
end
