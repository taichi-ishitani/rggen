module RGen
  module OutputBase
    module VerilogUtility
      class ClassDefinition < StructureDefinition
        def base(base_class)
          @base = base_class
        end

        private

        def header_code
          code_block do |code|
            code << :class << space   << @name
            code << space  <<:extends << space << @base unless @base.nil?
            code << semicolon
          end
        end

        def footer_code
          :endclass
        end
      end
    end
  end
end
