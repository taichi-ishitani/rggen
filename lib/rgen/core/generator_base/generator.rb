module RGen::GeneratorBase
  class Generator < RGen::Base::Component
    def generate_code(kind, mode, buffer)
      case mode
      when :top_down
        items.each do |item|
          item.generate_code(kind, buffer)
        end
        children.each do |child|
          child.generate_code(kind, mode, buffer)
        end
      when :bottom_up
        children.each do |child|
          child.generate_code(kind, mode, buffer)
        end
        items.each do |item|
          item.generate_code(kind, buffer)
        end
      end
    end
  end
end
