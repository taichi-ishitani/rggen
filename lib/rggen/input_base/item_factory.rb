module RgGen
  module InputBase
    class ItemFactory < Base::ItemFactory
      def active_item_factory?
        !passive_item_factory?
      end

      def passive_item_factory?
        @target_items.nil? && @target_item.passive_item?
      end
    end
  end
end
