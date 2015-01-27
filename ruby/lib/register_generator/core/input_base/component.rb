module RegisterGenerator::InputBase
  class Component < Base::Component
    def append_item(item)
      super(item)
      item.fields.each do |field|
        define_singleton_method(field) do
          item.__send__(field)
        end
      end
    end

    def fields
      items.flat_map(&:fields)
    end

    def validate
      items.each(&:validate)
      children.each(&:validate)
    end
  end
end
