module RGen::GeneratorBase
  class Item < RGen::Base::Item
    include TemplateUtility

    define_helpers do
      attr_reader :code_generator

      def generate_code(kind, &body)
        @code_generator ||= {}
        @code_generator[kind] = body
      end
    end

    def initialize(owner, configuration, source, context = nil)
      super(owner)
      @configuration  = configuration
      @source         = source
      @context        = context
    end

    attr_reader :configuration
    attr_reader :source
    attr_reader :context

    class_delegator :code_generator

    def generate_code(kind, buffer)
      return if code_generator.nil?
      return unless code_generator.key?(kind)
      instance_exec(buffer, &code_generator[kind])
    end
  end
end
