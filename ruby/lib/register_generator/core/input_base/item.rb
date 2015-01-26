module RegisterGenerator::InputBase
  class Item < Base::Item
    def self.define_field(field_name, args = {}, &body)
      @fields ||= []
      if fields.include?(field_name)
        return
      end

      if block_given?
        define_method(field_name, &body)
      elsif args.key?(:default)
        variable_name = "@#{field_name}"
        default_value = args[:default]
        define_method(field_name) do
          unless instance_variable_defined?(variable_name)
            default_value
          else
            instance_variable_get(variable_name)
          end
        end
      else
        attr_reader(field_name)
      end
      fields  << field_name
    end

    attr_class_reader :fields
  end
end
