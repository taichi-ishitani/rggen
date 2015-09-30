module RGen
  module Builder
    require_relative 'builder/value_item_entry'
    require_relative 'builder/list_item_entry'
    require_relative 'builder/item_store'
    require_relative 'builder/component_entry'
    require_relative 'builder/component_store'
    require_relative 'builder/category'
    require_relative 'builder/builder'
    require_relative 'builder/commands'
  end

  extend Builder::Commands
end
