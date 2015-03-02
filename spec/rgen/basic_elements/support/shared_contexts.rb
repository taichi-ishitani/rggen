shared_context 'configuration common' do
  class ConfigurationDummyLoader < RGen::InputBase::Loader
    support_types :txt

    def self.load_data(data = nil)
      @load_data  = data  if data
      @load_data
    end

    def self.clear
      @load_data  = nil
    end

    def load_file(file)
      self.class.load_data
    end
  end

  def build_configuration_factory
    f = RGen.generator.builder.build_factory(:configuration)
    f.register_loader(ConfigurationDummyLoader)
    f
  end

  let(:configuration_file) do
    'configuration.txt'
  end

  after do
    ConfigurationDummyLoader.clear
  end
end
