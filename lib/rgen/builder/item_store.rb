module RGen
  module Builder
    class ItemStore
      def initialize(base, factory)
        @base                 = base
        @factory              = factory
        @simple_item_entries  = {}
        @list_item_entries    = {}
        @enabled_entries      = []
      end

      attr_reader :base
      attr_reader :factory

      def define_simple_item(context, item_name, &body)
        create_item_entry(:simple, item_name, context, body)
      end

      def define_list_item(context, list_name, item_name = nil, &body)
        if item_name.nil?
          create_item_entry(:list, list_name, context, body)
        else
          define_list_item_class(list_name, item_name, context, body)
        end
      end

      def enable(*args)
        case args.size
        when 1
          enable_item_entries(args[0])
        when 2
          enable_list_item(args[0], args[1])
        else
          message = "wrong number of arguments (#{args.size} for 1..2)"
          fail ArgumentError, message
        end
      end

      def build_factories
        @enabled_entries.each_with_object({}) do |entry_name, factories|
          factories[entry_name] = (
            @simple_item_entries[entry_name] || @list_item_entries[entry_name]
          ).build_factory
        end
      end

      private

      def create_item_entry(entry_type, entry_name, context, body)
        klass = { simple: SimpleItemEntry, list: ListItemEntry }[entry_type]
        entry = klass.new(base, factory, context, &body)
        update_entries(entry_type, entry_name, entry)
      end

      def update_entries(entry_type, entry_name, entry)
        if entry_type == :simple
          @list_item_entries.delete(entry_name)
          @simple_item_entries[entry_name] = entry
        else
          @simple_item_entries.delete(entry_name)
          @list_item_entries[entry_name]  = entry
        end
      end

      def define_list_item_class(list_name, item_name, context, body)
        unless @list_item_entries.key?(list_name)
          message = "undefined list item entry: #{list_name}"
          fail RGen::BuilderError, message
        end
        entry = @list_item_entries[list_name]
        entry.define_list_item(item_name, context, &body)
      end

      def enable_item_entries(entry_name_or_names)
        Array(entry_name_or_names).each do |entry_name|
          next if @enabled_entries.include?(entry_name)
          next unless @simple_item_entries.key?(entry_name) ||
                      @list_item_entries.key?(entry_name)
          @enabled_entries  << entry_name
        end
      end

      def enable_list_item(list_name, item_name_or_names)
        return unless @list_item_entries.key?(list_name)
        @list_item_entries[list_name].enable(item_name_or_names)
      end
    end
  end
end
