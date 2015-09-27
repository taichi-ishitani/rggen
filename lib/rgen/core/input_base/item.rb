module RGen::InputBase
  class Item < RGen::Base::Item
    extend Forwardable

    define_helpers do
      attr_reader :builders
      attr_reader :validators

      def field(field_name, args = {}, &body)
        return if fields.include?(field_name)

        body  ||= lambda do
          if instance_variable_defined?(field_name.variablize)
            instance_variable_get(field_name.variablize)
          else
            args[:default]
          end
        end

        define_method(field_name, body)
        fields  << field_name
      end

      def fields
        @fields ||= []
      end

      def build(&body)
        @builders ||= []
        @builders << body
      end

      def validate(&body)
        @validators ||= []
        @validators << body
      end
    end

    def self.inherited(subclass)
      [:@fields, :@builders, :@validators].each do |variable|
        if instance_variable_defined?(variable)
          value = Array.new(instance_variable_get(variable))
          subclass.instance_variable_set(variable, value)
        end
      end
    end

    def_class_delegator :fields

    def build(*sources)
      return unless object_class.builders
      object_class.builders.each do |builder|
        instance_exec(*sources, &builder)
      end
    end

    def validate
      return unless object_class.validators
      object_class.validators.each do |validator|
        instance_exec(&validator)
      end
    end
  end
end
