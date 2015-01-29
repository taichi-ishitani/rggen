class RGen::InputBase::Item < RGen::Base::Item
  def self.define_field(field_name, args = {}, &body)
    @fields ||= []
    if fields.include?(field_name)
      return
    end

    unless block_given?
      variable_name = "@#{field_name}"
      default_value = args[:default]

      body  = Proc.new do
        unless instance_variable_defined?(variable_name)
          default_value
        else
          instance_variable_get(variable_name)
        end
      end
    end

    define_method(field_name, body)
    fields  << field_name
  end

  def self.parse(&body)
    @parser ||= body
  end

  def self.validate(&body)
    @validator  ||= body
  end

  attr_class_reader :fields
  attr_class_reader :parser
  attr_class_reader :validator

  def parse(*sources)
    instance_exec(*sources, &parser) if parser
  end

  def validate
    instance_exec(&validator) if validator
  end
end
