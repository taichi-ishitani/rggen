module RgGen
  module Configuration
    class ConfigurationFactory < InputBase::ComponentFactory
      def create_active_items(configuration, hash)
        active_item_factories.each do |name, factory|
          create_item(factory, configuration, hash[name])
        end
      end

      def load(file)
        return {} if file.nil? || file.empty?

        data  = load_file(file)
        if data.is_a?(Hash)
          data.symbolize_keys!
        else
          message = "Hash type required for configuration: #{data.class}"
          fail RgGen::LoadError, message
        end
      end
    end
  end
end
