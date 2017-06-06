module RgGen
  module Base
    class ItemFactory
      extend InternalStruct

      attr_writer :target_items
      attr_writer :target_item

      private

      def create_item(owner, *args)
        item  = create_item_object(owner, *args)
        return unless item.available?
        yield item if block_given?
        owner.add_item(item)
      end

      def create_item_object(owner, *args)
        klass ||= @target_items && select_target_item(*args)
        klass ||= @target_item
        klass.new(owner)
      end
    end
  end
end
