module RGen
  module OutputBase
    module VerilogUtility
      class ModuleDeclaration < StructureDeclaration
        def parameters(list)
          @parameters = list
        end

        def ports(list)
          @ports  = list
        end

        private

        def header_code
          code_block do |code|
            code << :module << space << @name << space
            parameter_declarations(code)
            port_declarations(code)
            code << semicolon
          end
        end

        def footer_code
          :endmodule
        end

        def parameter_declarations(code)
          return if @parameters.nil? || @parameters.empty?
          code << '#('
          declarations(@parameters, code)
          code << ')'
        end

        def port_declarations(code)
          code << '('
          declarations(@ports, code) if @ports && @ports.size > 0
          code << ')'
        end

        def declarations(list, code)
          indent(code, 2) do
            list.each_with_index do |d, i|
              code << comma << nl if i > 0
              code << d
            end
          end
        end
      end
    end
  end
end
