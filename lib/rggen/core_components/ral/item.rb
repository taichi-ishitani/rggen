module RgGen
  module RAL
    class Item < OutputBase::Item
      include         VerilogUtility
      template_engine ERBEngine

      def initialize(owner)
        super(owner)
        @identifiers            = []
        @variable_declarations  = Hash.new { |h, d| h[d]  = [] }
        @parameter_declarations = Hash.new { |h, d| h[d]  = [] }
      end

      attr_reader :identifiers

      class << self
        private
        def define_declaration_method(method_name)
          define_method(method_name) do |domain, handle_name, attributes = {}|
            attributes[:name] ||= handle_name
            declaration = create_declaration(method_name, attributes)
            add_declaration(method_name, domain, declaration)
            add_identifier(handle_name, declaration.identifier)
          end
        end
      end

      define_declaration_method :variable
      define_declaration_method :parameter

      def variable_declarations(domain = nil)
        domain || (return @variable_declarations)
        @variable_declarations[domain]
      end

      def parameter_declarations(domain = nil)
        domain || (return @parameter_declarations)
        @parameter_declarations[domain]
      end

      private

      def create_declaration(type, attributes)
        __send__("#{type}_declaration", attributes)
      end

      def add_identifier(handle_name, identifier)
        instance_variable_set(handle_name.variablize, identifier)
        attr_singleton_reader(handle_name)
        identifiers << handle_name
      end

      def add_declaration(type, domain, declaration)
        list  = instance_variable_get("@#{type}_declarations")
        list[domain]  << declaration
      end
    end
  end
end
