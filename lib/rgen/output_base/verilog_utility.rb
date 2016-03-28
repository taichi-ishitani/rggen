module RGen
  module OutputBase
    module VerilogUtility
      private

      def create_identifier(name)
        Identifier.new(name)
      end

      def create_declaration(declaration_type, attributes)
        Declaration.new(declaration_type, attributes)
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
        attributes[:name] = name
        create_declaration(:port, attributes)
      end

      def assign(lhs, rhs)
        "assign #{lhs} = #{rhs};"
      end

      def concat(expression, *other_expressions)
        expressions = Array[expression, *other_expressions]
        "{#{expressions.join(', ')}}"
      end

      def array(expression, *other_expressions)
        "'#{concat(expression, *other_expressions)}"
      end

      def string(expression)
        "\"#{expression}\""
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
end
