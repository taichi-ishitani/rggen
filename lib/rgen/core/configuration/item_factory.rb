module RGen
  module Configuration
    module ItemFactory
      def create(configuration, data = nil)
        item  = create_item(configuration, data)
        item.build(data) unless data.nil?
        item
      end
    end
  end
end
