simple_item :register_block, :irq_controller do
  rtl do
    available? { total_interrupts > 0 }

    build do
      output :irq, width: 1               , name: 'o_irq'
      logic  :ier, width: total_interrupts
      logic  :isr, width: total_interrupts
    end

    generate_code :module_item do |code|
      code << assign_ier << nl
      code << assign_isr << nl
      code << process_template
    end

    def total_interrupts
      @total_interrupts ||=
        register_block.source.bit_fields.count(&:irq?)
    end

    def assign_ier
      assign(ier, concat(*ier_fields.map(&:value)))
    end

    def assign_isr
      assign(isr, concat(*isr_fields.map(&:value)))
    end

    def isr_fields
      register_block.bit_fields.select(&:irq?)
    end

    def ier_fields
      isr_fields.each_with_object([]) do |isr_field, fields|
        fields << find_ier_field(isr_field.reference)
      end
    end

    def find_ier_field(reference)
      register_block.bit_fields.find { |field| field.name == reference.name }
    end
  end
end
