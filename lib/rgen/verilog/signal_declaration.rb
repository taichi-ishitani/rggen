module RGen
  module Verilog
    class SignalDeclaration
      def initialize(name, signal_attributes = {})
        @name       = name
        @type       = signal_attributes[:type] || ''
        @width      = width_code(signal_attributes)
        @dimensions = dimensions_code(signal_attributes)
      end

      attr_reader :name
      attr_reader :type
      attr_reader :width
      attr_reader :dimensions

      private

      def width_code(signal_attributes)
        width = signal_attributes[:width]
        return '' if width.nil?
        return '' if width == 1
        "[#{width - 1}:0]"
      end

      def dimensions_code(signal_attributes)
        dimensions  = signal_attributes[:dimensions]
        sv_enable   = signal_attributes[:sv_enable ]
        if dimensions.nil?
          ''
        elsif sv_enable.nil? || sv_enable
          dimensions.map { |dimension| "[#{dimension}]" }.join
        else
          dimensions.map { |dimension| "[0:#{dimension - 1}]" }.join
        end
      end
    end
  end
end
