module RGen
  class Generator
    def run(argv)
      parse_options!(argv)
    end

    private

    def parse_options!(argv)
      options = {}
      option_parser(options).parse!(argv)
      options
    end

    def option_parser(options)
      parser              = OptionParser.new
      parser.version      = RGen::VERSION
      parser.program_name = 'rgen'
      parser
    end
  end
end
