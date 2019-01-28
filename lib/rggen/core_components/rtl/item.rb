module RgGen
  module RTL
    class Item < OutputBase::Item
      include         VerilogUtility
      template_engine ERBEngine

      def initialize(owner)
        super(owner)
        @identifiers              = []
        @signal_declarations      = Hash.new { |h, d| h[d]  = [] }
        @port_declarations        = Hash.new { |h, d| h[d]  = [] }
        @parameter_declarations   = Hash.new { |h, d| h[d]  = [] }
      end

      attr_reader :identifiers

      def_delegator :@signal_declarations   , :[], :signal_declarations
      def_delegator :@port_declarations     , :[], :port_declarations
      def_delegator :@parameter_declarations, :[], :parameter_declarations

      class << self
        private

        def define_declaration_method(method_name)
          define_method(method_name) do |domain, handle_name, attributes = {}|
            attributes[:name] ||= handle_name
            declaration = create_declaration(method_name, attributes)
            add_declaration(method_name, domain, declaration)
            add_identifier(handle_name, declaration.identifier)
          end
          private method_name
        end
      end

      define_declaration_method :wire
      define_declaration_method :reg
      define_declaration_method :logic
      define_declaration_method :interface
      define_declaration_method :input
      define_declaration_method :output
      define_declaration_method :interface_port
      define_declaration_method :parameter
      define_declaration_method :localparam

      private

      def add_declaration(type, domain, attributes)
        case type
        when :wire, :reg, :logic
          @signal_declarations[domain] << variable_declaration(type, attributes)
        when :interface
          @signal_declarations[domain] << interface_instance(attributes)
        when :input, :output
          @port_declarations[domain] << port_declaration(type, attributes)
        when :interface_port
          @port_declarations[domain] << interface_port_declaration(attributes)
        when :parameter
          @parameter_declarations[domain] << parameter_declaration(type, attributes)
        when :localparam
          @localparam_declarations[domain] << parameter_declaration(type, attributes)
        end
      end

      def create_declaration(type, attributes)
        case type
        when :wire, :reg, :logic
          variable_declaration(attributes.merge(data_type: type))
        when :interface
          interface_instance(attributes)
        when :input, :output
          port_declaration(attributes.merge(direction: type))
        when :interface_port
          interface_port_declaration(attributes)
        when :parameter, :localparam
          parameter_declaration(attributes.merge(parameter_type: type))
        end
      end

      def add_declaration(type, domain, declaration)
        declarations  =
          case type
          when :wire, :reg, :logic, :interface
            @signal_declarations[domain]
          when :input, :output, :interface_port
            @port_declarations[domain]
          when :parameter, :localparam
            @parameter_declarations[domain]
          end
        declarations  << declaration
      end

      def add_identifier(handle_name, identifier)
        instance_variable_set(handle_name.variablize, identifier)
        attr_singleton_reader(handle_name)
        identifiers << handle_name
      end
    end
  end
end
