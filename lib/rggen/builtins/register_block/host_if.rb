list_item :register_block, :host_if do
  shared_context do
    attr_accessor :enabled_host_ifs
  end

  configuration do
    item_base do
      field :host_if do
        @host_if || shared_context.enabled_host_ifs.first
      end

      build do |value|
        @host_if  = value
      end
    end

    default_item do
    end

    factory do
      def select_target_item(value)
        @target_items[value]
      end

      def convert(value)
        find_host_if(value) do
          error "unknown host interface: #{value}"
        end
      end

      def find_host_if(value, &ifnone)
        shared_context.enabled_host_ifs.find(ifnone) do |host_if|
          host_if.to_sym.casecmp(value.to_sym) == 0
        end
      end
    end
  end

  rtl do
    shared_context.enabled_host_ifs = @enabled_items

    item_base do
      build do
        group(:host_if) do
          logic :command_valid , width: 1
          logic :write         , width: 1
          logic :read          , width: 1
          logic :address       , width: register_block.local_address_width
          logic :strobe        , width: configuration.byte_width
          logic :write_data    , width: configuration.data_width
          logic :write_mask    , width: configuration.data_width
          logic :response_ready, width: 1
          logic :read_data     , width: configuration.data_width
          logic :status        , width: 2
        end
      end
    end

    factory do
      def select_target_item(configuration, _register_block)
        @target_items[configuration.host_if]
      end
    end
  end
end
