module RgGen
  module Base
    module HierarchicalAccessors
      module RegisterMap
        def hierarchy
          :register_map
        end

        def register_blocks
          children
        end

        def registers
          register_blocks.flat_map(&:children)
        end

        def bit_fields
          registers.flat_map(&:children)
        end
      end

      module RegisterBlock
        def hierarchy
          :register_block
        end

        def register_map
          parent
        end

        def registers
          children
        end

        def bit_fields
          registers.flat_map(&:children)
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
          parent
        end

        def bit_fields
          children
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
          parent
        end
      end

      private

      EXTENSIONS  = [
        RegisterMap, RegisterBlock, Register, BitField
      ].freeze

      def define_hierarchical_accessors
        extend EXTENSIONS[level]
      end
    end
  end
end
