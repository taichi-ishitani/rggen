module RgGen
  module RegisterMap
    module RaiseError
      private

      def error(message, cell_or_position = nil)
        error_position  =
          case cell_or_position
          when GenericMap::Cell::Position then cell_or_position
          when GenericMap::Cell then cell_or_position.position
          else @position
          end
        fail RgGen::RegisterMapError.new(message, error_position)
      end
    end
  end
end
