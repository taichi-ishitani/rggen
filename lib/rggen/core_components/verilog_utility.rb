module RgGen
  module VerilogUtility
    include CodeUtility

    def create_blank_file(path)
      SourceFile.new(path)
    end

    private

    def create_identifier(name)
      Identifier.new(name)
    end

    def variable_declaration(attributes)
      Declaration.new(:variable, attributes)
    end

    def interface_instantiation(attributes)
      InterfaceInstantiation.new(attributes)
    end

    def port_declaration(attributes)
      Declaration.new(:port, attributes)
    end

    def interface_port_declaration(attributes)
      InterfacePortDeclaration.new(attributes)
    end

    def parameter_declaration(attributes)
      Declaration.new(:parameter, attributes)
    end

    def module_definition(name, &body)
      ModuleDefinition.new(name, &body).to_code
    end

    def package_definition(name, &body)
      PackageDefinition.new(name, &body).to_code
    end

    def class_definition(name, &body)
      ClassDefinition.new(name, &body).to_code
    end

    def function_definition(name, &body)
      SubroutineDefinition.new(:function, name, &body).to_code
    end

    def argument(name, attributes)
      port_declaration(attributes.merge(name: name))
    end

    def assign(lhs, rhs)
      "assign #{lhs} = #{rhs};"
    end

    def subroutine_call(subroutine, arguments = nil)
      "#{subroutine}(#{Array(arguments).join(', ')})"
    end

    def concat(expression_or_expressions)
      "{#{Array(expression_or_expressions).join(', ')}}"
    end

    def array(expression_or_expressions)
      "'#{concat(expression_or_expressions)}"
    end

    def bin(value, width)
      format("%d'b%0*b", width, width, value)
    end

    def dec(value, width)
      format("%d'd%d", width, value)
    end

    def hex(value, width)
      print_width = (width + 3) / 4
      format("%d'h%0*x", width, print_width, value)
    end
  end
end
