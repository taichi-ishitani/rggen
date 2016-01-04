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
        @loaders  << Class.new(loader_base, &body).tap do |l|
          l.supported_types = Array(type_or_types)
        end
      end

      def build_factory
        super.tap do |f|
          f.loaders = @loaders
        end
      end
    end
  end
end
