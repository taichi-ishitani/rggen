module RGen
  module Base
    module HierarchicalAccessor
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

      def define_hierarchical_accessor
        case @level
        when 0
          extend RegisterMap
        when 1
          extend RegisterBlock
        when 2
          extend Register
        when 3
          extend BitField
        end
      end
    end
  end
end
