module RGen::GeneratorBase
  class Generator < RGen::Base::Component
    def generate_code(kind, mode, buffer)
      case mode
      when :top_down
        generate_item_code(kind, buffer)
        generate_child_code(kind, mode, buffer)
      when :bottom_up
        generate_child_code(kind, mode, buffer)
        generate_item_code(kind, buffer)
      end
    end

    private

    def generate_child_code(kind, mode, buffer)
      children.each do |child|
        child.generate_code(kind, mode, buffer)
      end
    end

    def generate_item_code(kind, buffer)
      items.each do |item|
        item.generate_code(kind, buffer)
      end
    end
  end
end
