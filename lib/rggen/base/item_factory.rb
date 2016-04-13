module RgGen
  module Base
    class ItemFactory
      attr_writer :target_items
      attr_writer :target_item

      def create(owner, *args)
        create_item(owner, *args)
      end

      private

      def create_item(owner, *args)
        klass ||= @target_items && select_target_item(*args)
        klass ||= @target_item
        klass.new(owner)
      end
    end
  end
end
