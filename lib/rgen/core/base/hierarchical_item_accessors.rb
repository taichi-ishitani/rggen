module RGen
  module Base
    module HierarchicalItemAccessors
      module RegisterMap
        def hierarchy
          :register_map
        end

        def register_map
          __start_position
        end
      end

      module RegisterBlock
        def hierarchy
          :register_block
        end

        def register_map
          register_block.parent
        end

        def register_block
          __start_position
        end
      end

      module Register
        def hierarchy
          :register
        end

        def register_map
          register_block.parent
        end

        def register_block
          register.parent
        end

        def register
          __start_position
        end
      end

      module BitField
        def hierarchy
          :bit_field
        end

        def register_map
          register_block.parent
        end

        def register_block
          register.parent
        end

        def register
          bit_field.parent
        end

        def bit_field
          __start_position
        end
      end

      private

      EXTENSIONS  = [
        RegisterMap, RegisterBlock, Register, BitField
      ].freeze

      def define_hierarchical_item_accessors
        extend EXTENSIONS[@owner.level]
      end
    end
  end
end
