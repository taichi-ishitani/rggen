module RgGen
  module RegisterMap
    class RegisterMapFactory < ComponentFactory
      def create_children(register_map, configuration, map)
        map.sheets.each do |sheet|
          create_child(register_map, configuration, sheet)
        end
      end

      def load(file)
        map = load_file(file)
        return map if map.is_a?(GenericMap)
        message = "GenericMap type required for register map: #{map.class}"
        raise RgGen::LoadError, message
      end
    end
  end
end
