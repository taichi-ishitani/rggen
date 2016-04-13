module RgGen
  module Base
    class Item
      extend Forwardable

      def initialize(owner)
        @owner  = owner
      end

      attr_reader :owner

      def self.define_helpers(&body)
        singleton_class.class_exec(&body) if block_given?
      end

      def self.inherit_class_instance_variable(variable_name, parent_class, &block)
        return unless parent_class.instance_variable_defined?(variable_name)
        v = parent_class.instance_variable_get(variable_name)
        v = block.call(v) if block_given?
        instance_variable_set(variable_name, v)
      end
    end
  end
end
