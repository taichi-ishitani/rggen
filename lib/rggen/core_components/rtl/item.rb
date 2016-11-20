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
      define_declaration_method :input
      define_declaration_method :output
      define_declaration_method :parameter
      define_declaration_method :localparam

      def group(group_name, &body)
        create_group(group_name)
        instance_exec(&body)
        @group  = nil
      end

      def add_declaration(type, attributes)
        attribute_key, declaration_type, declarations =
          case type
          when :wire, :reg, :logic
            [:data_type, :variable, signal_declarations]
          when :input, :output
            [:direction, :port, port_declarations]
          when :parameter
            [:parameter_type, :parameter, parameter_declarations]
          when :localparam
            [:parameter_type, :parameter, localparam_declarations]
          end
        attributes[attribute_key] = type
        declarations << create_declaration(declaration_type, attributes)
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
