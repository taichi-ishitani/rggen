module RgGen
  module RAL
    class Item < OutputBase::Item
      use_verilog_utility

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
            add_identifier(handle_name, attributes[:name])
            add_declaration(method_name, domain, attributes)
          end
        end
      end

      define_declaration_method :variable
      define_declaration_method :parameter

      def variable_declarations(domain = nil)
        return @variable_declarations if domain.nil?
        @variable_declarations[domain]
      end

      def parameter_declarations(domain = nil)
        return @parameter_declarations if domain.nil?
        @parameter_declarations[domain]
      end

      private

      def add_identifier(handle_name, name)
        create_identifier(name).tap do |i|
          instance_variable_set(handle_name.variablize, i)
          attr_singleton_reader(handle_name)
          identifiers << handle_name
        end
      end

      def add_declaration(type, domain, attributes)
        create_declaration(type, attributes).tap do |d|
          declarations  = {
            variable: @variable_declarations,
            parameter: @parameter_declarations
          }.fetch(type)
          declarations[domain] << d
        end
      end
    end
  end
end
