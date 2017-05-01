module RgGen
  module RTL
    class Item < OutputBase::Item
      include         VerilogUtility
      template_engine ERBEngine

      def initialize(owner)
        super(owner)
        @identifiers              = []
        @signal_declarations      = []
        @port_declarations        = []
        @parameter_declarations   = []
        @localparam_declarations  = []
      end

      attr_reader :identifiers
      attr_reader :signal_declarations
      attr_reader :port_declarations
      attr_reader :parameter_declarations
      attr_reader :localparam_declarations

      private

      class << self
        private

        def define_declaration_method(method_name)
          define_method(method_name) do |handle_name, attributes = {}|
            attributes[:name] ||= handle_name
            add_identifier(handle_name, attributes[:name])
            add_declaration(method_name, attributes)
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

      def group(group_name, &body)
        create_group(group_name)
        instance_exec(&body)
        @group  = nil
      end

      def add_declaration(type, attributes)
        case type
        when :wire, :reg, :logic
          signal_declarations << variable_declaration(type, attributes)
        when :interface
          signal_declarations << interface_instantiation(attributes)
        when :input, :output
          port_declarations << port_declaration(type, attributes)
        when :interface_port
          port_declarations << interface_port_declaration(attributes)
        when :parameter
          parameter_declarations  << parameter_declaration(type, attributes)
        when :localparam
          localparam_declarations << parameter_declaration(type, attributes)
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
        (@group || self).instance_exec do
          instance_variable_set(handle_name.variablize, identifier)
          attr_singleton_reader(handle_name)
        end
        identifiers << handle_name if @group.nil?
      end

      def create_group(group_name)
        instance_variable_set(group_name.variablize, Object.new)
        attr_singleton_reader(group_name)
        identifiers << group_name
        @group      = __send__(group_name)
      end
    end
  end
end
