module RgGen
  module Base
    class ItemFactory
      attr_writer :target_items
      attr_writer :target_item

      private

      def create_item(owner, *args, &block)
        item  = create_item_object(owner, *args)
        if item.available?
          block.call(item) if block_given?
          owner.add_item(item)
        end
      end

      def create_item_object(owner, *args)
        klass ||= @target_items && select_target_item(*args)
        klass ||= @target_item
        klass.new(owner)
      end
    end
  end
end
