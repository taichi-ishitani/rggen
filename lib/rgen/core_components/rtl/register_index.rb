module RGen
  module Rtl
    module RegisterIndex
      private

      def register_index
        register_block.registers.index do |r|
          r.equal?(register)
        end
      end
    end
  end
end
