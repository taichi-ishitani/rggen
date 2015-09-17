module RGen::Base
  class ItemFactory
    def initialize(factory_type = :value_item_factory)
      @factory_type = factory_type
    end

    def register(item, item_name = nil)
      if @factory_type == :value_item_factory
        @target_item  ||= item
      else
        @target_items ||= {}
        @target_items[item_name]  = item
      end
    end

    def create(owner, *args)
      create_item(owner, *args)
    end

    private

    def create_item(owner, *args)
      if @factory_type == :value_item_factory
        @target_item.new(owner)
      else
        select_target_item(*args).new(owner)
      end
    end
  end
end