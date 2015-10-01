module RGen::InputBase
  class Item < RGen::Base::Item
    define_helpers do
      attr_reader :builders
      attr_reader :validators

      def field(field_name, options = {}, &body)
        return if fields.include?(field_name)

        define_method(field_name) do
          field_method(field_name, options, body)
        end

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

    class_delegator :fields
    class_delegator :builders
    class_delegator :validators

    def build(*sources)
      return unless builders
      builders.each do |builder|
        instance_exec(*sources, &builder)
      end
    end

    def validate
      return if @validated
      return unless validators
      validators.each do |validator|
        instance_eval(&validator)
      end
      @validated  = true
    end

    private

    def field_method(field_name, options, body)
      validate if options[:need_validation]
      if body
        instance_exec(&body)
      elsif options[:forward_to_helper]
        self.class.send(field_name)
      elsif options.key?(:forward_to)
        __send__(options[:forward_to])
      else
        default_field_method(field_name, options[:default])
      end
    end

    def default_field_method(field_name, default_value)
      if field_name =~ /\A([a-zA-Z0-9]\w*)\?\z/
        variable_name = Regexp.last_match[1].variablize
      else
        variable_name = field_name.variablize
      end

      if instance_variable_defined?(variable_name)
        instance_variable_get(variable_name)
      else
        default_value
      end
    end
  end
end
