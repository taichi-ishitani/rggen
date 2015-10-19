module RGen
  module Base
    class ItemFactory
      attr_writer :target_item
      attr_writer :target_items

      def create(owner, *args)
        create_item(owner, *args)
      end

      private

      def create_item(owner, *args)
        (@target_item || select_target_item(*args)).new(owner)
      end
    end
  end
end
