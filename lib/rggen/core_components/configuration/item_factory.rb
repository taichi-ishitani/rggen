module RgGen
  module Configuration
    class ItemFactory < InputBase::ItemFactory
      include RaiseError

      def create(configuration, data = nil)
        data  &&= convert(data)
        create_item(configuration, data) do |item|
          item.build(data) unless data.nil?
        end
      end

      private

      def convert(data)
        data
      end
    end
  end
end
