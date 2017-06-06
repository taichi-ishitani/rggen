module RgGen
  class Options
    extend Forwardable

    class OptionSwitch
      def initialize(kind)
        @kind = kind
      end

      def on(parser, options)
        parser.on(*args) do |value|
          parser.instance_exec(value, options, @kind, &body)
        end
      end

      attr_setter :short
      attr_setter :long
      attr_setter :option_class

      def default(value = nil, &block)
        if block_given?
          @default  = block
        elsif value
          @default  = proc { value }
        else
          @default && @default.call
        end
      end

      def description(value = nil)
        if value
          @description  = value
        elsif @description || @default
          ''.tap do |d|
            d << @description if @description
            d << "(default: #{default})" if default
          end
        end
      end

      def body(&block)
        if block_given?
          @body = block
        else
          @body || proc { |v, o, k| o[k] = v }
        end
      end

      private

      def args
        [@short, @long, @option_class, description].compact
      end
    end

    class << self
      def option_switches
        @option_switches ||= {}
      end

      def add_option_switch(kind, &block)
        option_switches[kind] = OptionSwitch.new(kind)
        option_switches[kind].instance_exec(&block)
      end
    end

    def_class_delegator :option_switches
    def_delegator :@options, :[]

    def initialize
      @options  = Hash.new { |h, k| h[k]  = option_switches[k].default }
    end

    def parse(args)
      option_parser.parse!(args)
    end

    private

    def option_parser
      OptParse.new do |parser|
        parser.version      = RgGen::VERSION
        parser.program_name = 'rggen'
        parser.banner       = 'Usage: rggen [options] REGISTER_MAP'
        define_option_switches(parser)
      end
    end

    def define_option_switches(parser)
      option_switches.each_value { |switch| switch.on(parser, @options) }
    end
  end
end
