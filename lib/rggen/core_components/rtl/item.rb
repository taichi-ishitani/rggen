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
        @localparam_declarations  = Hash.new { |h, d| h[d]  = [] }
      end

      attr_reader :identifiers

      def_delegator :@signal_declarations    , :[], :signal_declarations
      def_delegator :@port_declarations      , :[], :port_declarations
      def_delegator :@parameter_declarations , :[], :parameter_declarations
      def_delegator :@localparam_declarations, :[], :localparam_declarations

      class << self
        private

        def define_declaration_method(method_name)
          define_method(method_name) do |domain, handle_name, attributes = {}|
            attributes[:name] ||= handle_name
            add_identifier(handle_name, attributes[:name])
            add_declaration(method_name, domain, attributes)
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

      def variable_declaration(data_type, attributes)
        super(attributes.merge(data_type: data_type))
      end

      def port_declaration(direction, attributes)
        super(attributes.merge(direction: direction))
      end

      def parameter_declaration(parameter_type, attributes)
        super(attributes.merge(parameter_type: parameter_type))
      end

      def add_identifier(handle_name, name)
        identifier  = create_identifier(name)
        instance_exec do
          instance_variable_set(handle_name.variablize, identifier)
          attr_singleton_reader(handle_name)
        end
        identifiers << handle_name
      end
    end
  end
end
