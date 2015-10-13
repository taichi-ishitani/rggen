module RGen
  module Configuration
    require_relative 'configuration/raise_error'

    RGen.component_store(:configuration) do
      entry do
        component_class(InputBase::Component)

        component_factory(InputBase::ComponentFactory) do
          def create_active_items(configuration, hash)
            active_item_factories.each do |name, factory|
              create_item(factory, configuration, hash[name])
            end
          end

          def load(file)
            return {} if file.nil? || file.empty?

            data  = load_file(file)
            if data.kind_of?(Hash)
              data.symbolize_keys!
            else
              message = "Hash type required for configuration: #{data.class}"
              fail RGen::LoadError, message
            end
          end
        end

        item_base(InputBase::Item) do
          include RaiseError
        end

        item_factory(InputBase::ItemFactory) do
          include RaiseError

          def create(configuration, data = nil)
            item  = create_item(configuration, data)
            item.build(data) unless data.nil?
            item
          end
        end
      end

      loader_base InputBase::Loader
    end
  end
end
