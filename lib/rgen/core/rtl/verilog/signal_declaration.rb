module RGen
  module Rtl
    module Verilog
      class SignalDeclaration
        def initialize(name, signal_attributes = {})
          @name       = name
          @type       = signal_attributes[:type] || ''
          @width      = width_code(signal_attributes)
          @dimension  = dimension_code(signal_attributes)
        end

        attr_reader :name
        attr_reader :type
        attr_reader :width
        attr_reader :dimension

        private

        def width_code(signal_attributes)
          width = signal_attributes[:width]
          (width && "[#{width - 1}:0]") || ''
        end

        def dimension_code(signal_attributes)
          dimension = signal_attributes[:dimension]
          sv_enable = signal_attributes[:sv_enable]
          if dimension.nil?
            ''
          elsif sv_enable.nil? || sv_enable
            "[#{dimension}]"
          else
            "[0:#{dimension - 1}]"
          end
        end
      end
    end
  end
end
