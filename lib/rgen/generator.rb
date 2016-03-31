module RGen
  class Generator
    Context = Struct.new(:options, :configuration, :register_map) do
      def initialize
        super
        self.options  = {}
      end
    end

    class Option
      def initialize(kind)
        @kind = kind
      end

      attr_accessor :short
      attr_accessor :long
      attr_writer   :default
      attr_writer   :description
      attr_writer   :body

      def on(parser, options)
        options[@kind]  = @default if @default
        parser.on(*args) do |value|
          parser.instance_exec(value, options, @kind, &body)
        end
      end

      def args
        [@short, @long, description].compact
      end

      def description
        return nil unless @description || @default
        d = ''
        d << @description.to_s
        d << "(default: #{@default})" if @default
        d
      end

      def body
        @body || default_body
      end

      def default_body
        proc do |value, options, kind|
          options[kind] = value
        end
      end
    end

    class << self
      def options
        @options  ||= []
      end

      private

      def add_option(kind, &body)
        options << Option.new(kind)
        body.call(options.last)
      end
    end

    add_option :setup do |option|
      option.long         = '--setup FILE'
      option.default      = File.join(RGEN_HOME, 'setup', 'default.rb')
      option.description  = 'Specify a setup file to set up RGen tool'
    end

    add_option :configuration do |option|
      option.short        = '-c'
      option.long         = '--configuration FILE'
      option.description  = 'Specify a configuration file ' \
                            'for generated source code'
    end

    add_option :output do |option|
      option.short        = '-o'
      option.long         = '--output DIR'
      option.default      = './'
      option.description  = 'Specify output directory'
    end

    add_option :version do |option|
      option.short        = '-v'
      option.long         = '--version'
      option.description  = 'Display the version'
      option.body         = proc do
        puts ver
        exit
      end
    end

    add_option :help do |option|
      option.short        = '-h'
      option.long         = '--help'
      option.description  = 'Display this message'
      option.body         = proc do
        puts help
        exit
      end
    end

    def run(argv)
      Context.new.tap do |context|
        parse_options(argv, context)
        load_setup(context)
        load_configuration(context)
        load_register_map(context, argv.first)
        write_files(context)
      end
    end

    private

    def parse_options(argv, context)
      option_parser(context.options).parse!(argv)
    end

    def option_parser(options)
      OptionParser.new do |parser|
        parser.version      = RGen::VERSION
        parser.program_name = 'rgen'
        parser.banner       = 'Usage: rgen [options] REGISTER_MAP'
        add_option_switches(parser, options)
      end
    end

    def add_option_switches(parser, options)
      self.class.options.each do |option|
        option.on(parser, options)
      end
    end

    def load_setup(context)
      load(context.options[:setup])
    end

    def build_factory(component_name)
      RGen.builder.build_factory(component_name)
    end

    def load_configuration(context)
      context.configuration =
        build_factory(:configuration).create(context.options[:configuration])
    end

    def load_register_map(context, file)
      context.register_map  =
        build_factory(:register_map).create(context.configuration, file)
    end

    def write_files(context)
      file_generators(context).each do |generator|
        generator.write_file(context.options[:output])
      end
    end

    def file_generators(context)
      RGen.builder.stored_output_components.map do |component|
        build_factory(component).create(
          context.configuration, context.register_map
        )
      end
    end
  end
end
