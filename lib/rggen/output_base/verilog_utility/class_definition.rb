module RgGen
  module OutputBase
    module VerilogUtility
      class ClassDefinition < StructureDefinition
        attr_setter :base
        attr_setter :parameters
        attr_setter :variables

        def to_code
          bodies.unshift(variables_declarations) if variables?
          super
        end

        private

        def header_code
          code_block do |code|
            code << :class << space   << @name
            paraemter_declarations(code) if parameters?
            code << space  <<:extends << space << @base unless @base.nil?
            code << semicolon
          end
        end

        def footer_code
          :endclass
        end

        def parameters?
          !(@parameters.nil? || @parameters.empty?)
        end

        def variables?
          !(@variables.nil? || @variables.empty?)
        end

        def paraemter_declarations(code)
          wrap(code, '#(', ')') do
            indent(code, 2) do
              @parameters.each_with_index do |d, i|
                code << comma << nl if i > 0
                code << d
              end
            end
          end
        end

        def variables_declarations
          lambda do |code|
            variables.each do |variable|
              code << variable << semicolon << nl
            end
          end
        end
      end
    end
  end
end
