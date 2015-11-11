module RGen
  module Rtl
    class Item < OutputBase::Item
      def identifiers
        @identifiers  ||= []
      end

      def signal_declarations
        @signal_declarations  ||= []
      end

      def port_declarations
        @port_declarations  ||= []
      end

      def parameter_declarations
        @parameter_declarations ||= []
      end

      def localparam_declarations
        @localparam_declarations  ||= []
      end

      private

      [:wire, :reg, :logic].each do |type|
        define_method(type) do |handle_name, attributes = {}|
          attributes[:type] = type
          declarations      = signal_declarations
          declare(SignalDeclaration, declarations, handle_name, attributes)
        end
        private type
      end

      [:input, :output].each do |direction|
        define_method(direction) do |handle_name, attributes = {}|
          attributes[:direction]  = direction
          declarations            = port_declarations
          declare(PortDeclaration, declarations, handle_name, attributes)
        end
        private direction
      end

      [:parameter, :localparam].each do |type|
        define_method(type) do |handle_name, attributes = {}|
          attributes[:type] = type
          declarations      =
            case type
            when :parameter  then parameter_declarations
            when :localparam then localparam_declarations
            end
          declare(ParameterDeclaration, declarations, handle_name, attributes)
        end
        private type
      end

      def group(group_name, &body)
        create_group(group_name)
        instance_exec(&body)
        @group  = nil
      end

      def declare(klass, declarations, handle_name, attributes)
        name  = (attributes[:name] || handle_name).to_s
        create_identifier(handle_name, name)
        declarations  << klass.new(name, attributes)
      end

      def create_identifier(handle_name, name)
        context = @group || self
        context.instance_variable_set(handle_name.variablize, Identifier.new(name))
        context.attr_singleton_reader(handle_name)
        identifiers << handle_name if @group.nil?
      end

      def create_group(group_name)
        instance_variable_set(group_name.variablize, Object.new)
        attr_singleton_reader(group_name)
        identifiers << group_name
        @group      = __send__(group_name)
      end

      def assign(lhs, rhs)
        "assign #{lhs} = #{rhs};"
      end

      def concat(expression, *other_expressions)
        expressions = Array[expression, *other_expressions]
        "{#{expressions.join(', ')}}"
      end

      def bin(value, width)
        sprintf("%d'b%0*b", width, width, value)
      end

      def dec(value, width)
        sprintf("%d'd%d", width, value)
      end

      def hex(value, width)
        print_width = (width + 3) / 4
        sprintf("%d'h%0*x", width, print_width, value)
      end
    end
  end
end
