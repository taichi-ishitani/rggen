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
      delegate [:local_address_width] => :register_block
      delegate [:data_width] => :configuration

      build do
        interface :register_if,
                  type: :rggen_register_if,
                  parameters: [local_address_width, data_width],
                  dimensions: [total_registers]
      end

      def total_registers
        register_block.registers.sum(0, &:count)
      end
    end

    factory do
      def select_target_item(configuration, _register_block)
        @target_items[configuration.host_if]
      end
    end
  end
end
