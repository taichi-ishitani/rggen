module RGen
  module Builder
    class ComponentStore
      def initialize(builder, component_name)
        @builder        = builder
        @component_name = component_name
        @entries        = []
      end

      def entry(associated_category_or_categories = nil, &body)
        if associated_category_or_categories.nil?
          @entries << create_new_entry(nil, body)
        else
          Array(associated_category_or_categories).each do |category|
            @entries << create_new_entry(category, body)
          end
        end
      end

      def build_factory
        factories = @entries.map(&:build_factory)
        factories.each_cons(2) do |factory_pair|
          factory_pair[0].child_factory = factory_pair[1]
        end
        factories.first.root_factory
        factories.first
      end

      private

      def create_new_entry(associated_category, body)
        ComponentEntry.new.tap do |new_entry|
          new_entry.instance_exec(&body)
          @builder.categories.each do |name, category|
            next if associated_category && name != associated_category
            category.add_item_store(@component_name, new_entry.item_store)
          end if new_entry.item_store
        end
      end
    end
  end
end
