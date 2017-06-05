simple_item :register_block, :irq_controller do
  rtl do
    available? { register_block.source.bit_fields.any?(&:irq?) }

    build do
      output :register_block, :irq, width: 1               , name: 'o_irq'
      logic  :register_block, :ier, width: total_interrupts
      logic  :register_block, :isr, width: total_interrupts
    end

    generate_code :register_block do |code|
      code << assign_ier << nl
      code << assign_isr << nl
      code << process_template
    end

    def assign_ier
      assign(ier, concat(ier_fields.map(&:value)))
    end

    def assign_isr
      assign(isr, concat(isr_fields.map(&:value)))
    end

    def isr_fields
      @isr_fields ||= register_block.bit_fields.select(&:irq?)
    end

    def ier_fields
      @ier_fields ||= isr_fields.each_with_object([]) do |isr_field, fields|
        fields << find_ier_field(isr_field.reference)
      end
    end

    def find_ier_field(reference)
      register_block.bit_fields.find_by(name: reference.name)
    end

    def total_interrupts
      @total_interrupts ||= isr_fields.sum(0, &:width)
    end
  end
end
