module RgGen
  class Generator
    Context = Struct.new(:options, :configuration, :register_map)

    def run(argv)
      Context.new.tap do |context|
        parse_options(argv, context)
        load_setup(context)
        load_configuration(context)
        load_register_map(context, argv)
        write_files(context)
      end
    rescue RgGen::RuntimeError, OptionParser::ParseError => e
      abort "[#{e.class.lastname}] #{e.message}"
    end

    private

    def parse_options(argv, context)
      context.options = Options.parse(argv)
    end

    def load_setup(context)
      context.options[:setup].tap do |setup|
        File.exist?(setup) || (
          raise RgGen::LoadError, "cannot load such file -- #{setup}"
        )
        load(setup)
      end
    end

    def build_factory(component_name)
      RgGen.builder.build_factory(component_name)
    end

    def load_configuration(context)
      context.configuration =
        build_factory(:configuration).create(context.options[:configuration])
    end

    def load_register_map(context, argv)
      raise RgGen::LoadError, 'no register map is specified' if argv.empty?
      context.register_map  =
        build_factory(:register_map).create(context.configuration, argv.first)
    end

    def write_files(context)
      file_generators(context).each do |generator|
        generator.write_file(context.options[:output])
      end unless context.options[:load_only]
    end

    def file_generators(context)
      available_output_components(context).map do |component|
        build_factory(component).create(
          context.configuration, context.register_map
        )
      end
    end

    def available_output_components(context)
      RgGen.builder.stored_output_components.reject do |component|
        context.options[:disable].include?(component)
      end
    end
  end
end
