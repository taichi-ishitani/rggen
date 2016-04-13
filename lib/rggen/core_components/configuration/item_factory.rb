module RgGen
  module Configuration
    class ItemFactory < InputBase::ItemFactory
      include RaiseError

      def create(configuration, data = nil)
        item  = create_item(configuration, data)
        item.build(data) unless data.nil?
        item
      end
    end
  end
end
