module RgGen
  module OutputBase
    class ItemFactory < Base::ItemFactory
      def create(owner, *args)
        create_item(owner, *args)
      end
    end
  end
end
