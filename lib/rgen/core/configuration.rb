module RGen
  module Configuration
    require_relative 'configuration/raise_error'
    require_relative 'configuration/factory'

    RGen.component_store(:configuration) do
      entry do
        component_class   InputBase::Component
        component_factory Factory

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
