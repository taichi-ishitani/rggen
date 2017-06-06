module RgGen
  Options.add_option_switch :setup do
    long        '--setup FILE'
    description 'Specify a setup file to set up RgGen tool'
    default { ENV['RGGEN_DEFAULT_SETUP_FILE'] || default_setup }

    def default_setup
      File.join(RgGen::RGGEN_HOME, 'setup', 'default.rb')
    end
  end

  Options.add_option_switch :configuration do
    short       '-c'
    long        '--configuration FILE'
    description 'Specify a configuration file for generated source code'
    default { ENV['RGGEN_DEFAULT_CONFIGURATION_FILE'] }
  end

  Options.add_option_switch :output do
    short       '-o'
    long        '--output DIR'
    description 'Specify output directory'
    default     '.'
  end

  Options.add_option_switch :disable do
    long          '--disable TYPE1[,TYPE2,...]'
    option_class  Array
    description   'Disable the given output file type(s)'
    default { [] }
    body { |v, o, k| o[k].concat(v.map(&:to_sym)) }
  end

  Options.add_option_switch :show_home do
    long        '--show-home'
    description 'Display the path of RgGen tool home directory'
    body { puts RgGen::RGGEN_HOME; exit }
  end

  Options.add_option_switch :version do
    short       '-v'
    long        '--version'
    description 'Display the version'
    body { puts ver; exit }
  end

  Options.add_option_switch :help do
    short       '-h'
    long        '--help'
    description 'Display this message'
    body  { puts help; exit }
  end
end
