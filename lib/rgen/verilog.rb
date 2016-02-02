module RGen
  module Verilog
    private

    def create_identifier(name)
      Identifier.new(name)
    end

    def create_declaration(declaration_type, attributes)
      Declaration.new(declaration_type, attributes)
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
