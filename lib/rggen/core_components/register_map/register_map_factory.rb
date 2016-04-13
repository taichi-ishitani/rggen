module RgGen
  module RegisterMap
    class RegisterMapFactory < InputBase::ComponentFactory
      def create_children(register_map, configuration, map)
        map.sheets.each do |sheet|
          create_child(register_map, configuration, sheet)
        end
      end

      def load(file)
        map = load_file(file)
        if map.is_a?(GenericMap)
          map
        else
          message = "GenericMap type required for register map: #{map.class}"
          fail RgGen::LoadError, message
        end
      end
    end
  end
end
