module RgGen
  module Base
    class Item
      extend Forwardable

      class << self
        def define_helpers(&body)
          singleton_class.class_exec(&body) if block_given?
        end

        def available?(&body)
          define_method(:available?, &body)
        end

        def inherit_class_instance_variable(variable_name, klass, &block)
          return unless klass.instance_variable_defined?(variable_name)
          v = klass.instance_variable_get(variable_name)
          v = block.call(v) if block_given?
          instance_variable_set(variable_name, v)
        end
      end

      def initialize(owner)
        @owner  = owner
      end

      attr_reader :owner

      def available?
        true
      end
    end
  end
end
