module RGen
  class Generator
    class << self
      Option = Struct.new(:short, :long, :default, :description)

      def options
        @options  ||= {}
      end

      private

      def add_option(option_name, &body)
        options[option_name]  = Option.new
        body.call(options[option_name])
      end
    end

    add_option :setup do |option|
      option.long     = '--setup FILE'
      option.default  = File.join(RGEN_HOME, 'setup', 'default.rb')
    end

    add_option :configuration do |option|
      option.short  = '-c'
      option.long   = '--configuration FILE'
    end

    add_option :output do |option|
      option.short    = '-o'
      option.long     = '--output DIR'
      option.default  = './'
    end

    def run(argv)
      options = parse_options(argv)
      load_setup(options[:setup])
      configuration = load_configuration(options[:configuration])
      register_map  = load_register_map(configuration, argv.first)
      write_files(configuration, register_map, options[:output])
    end

    private

    def parse_options(argv)
      options = {}
      option_parser(options).parse!(argv)
      options
    end

    def option_parser(options)
      OptionParser.new do |parser|
        parser.version      = RGen::VERSION
        parser.program_name = 'rgen'
        add_option_switches(parser, options)
      end
    end

    def add_option_switches(parser, options)
      self.class.options.each do |name, option|
        options[name] = option.default
        parser.on(*option.values.compact) do |v|
          options[name] = v
        end
      end
    end

    def load_setup(file)
      load(file)
    end

    def build_factory(component_name)
      RGen.builder.build_factory(component_name)
    end

    def load_configuration(file)
      build_factory(:configuration).create(file)
    end

    def load_register_map(configuration, file)
      build_factory(:register_map).create(configuration, file)
    end

    def write_files(configuration, register_map, output)
      file_generators(configuration, register_map).each do |generator|
        generator.write_file(output)
      end
    end

    def file_generators(configuration, register_map)
      output_components = RGen.builder.stored_components.reject do |component|
        [:configuration, :register_map].include?(component)
      end
      output_components.map do |component|
        build_factory(component).create(configuration, register_map)
      end
    end
  end
end
