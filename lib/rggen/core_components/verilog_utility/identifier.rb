module RgGen
  module VerilogUtility
    class Identifier
      include InputBase::RegxpPatterns

      def initialize(name, width = nil, array_dimensions = nil, array_format = nil)
        @name             = name
        @width            = width
        @array_dimensions = array_dimensions
        @array_format     = array_format || :unpacked
      end

      def to_s
        @name.to_s
      end

      def [](array_index_or_msb, lsb = array_index_or_msb)
        if array_index_or_msb.nil?
          self
        else
          new_name  =
            if array_index_or_msb.is_a?(Array)
              "#{@name}#{array_selection(array_index_or_msb)}"
            elsif array_index_or_msb == lsb
              "#{@name}[#{array_index_or_msb}]"
            else
              "#{@name}[#{array_index_or_msb}:#{lsb}]"
            end
          Identifier.new(new_name, nil, nil, nil)
        end
      end

      TYPE_CONVERSIONS  = [
        :to_a, :to_ary, :to_hash, :to_int, :to_io, :to_proc, :to_regexp, :to_str
      ].freeze

      def method_missing(name, *args)
        args.size.zero? || (return super)
        TYPE_CONVERSIONS.include?(name) && (return super)
        (name =~ variable_name) || (return super)
        Identifier.new("#{@name}.#{name}", nil, nil, nil)
      end

      def respond_to_missing?(symbol, include_private)
        TYPE_CONVERSIONS.include?(symbol) && (return super)
        symbol =~ variable_name || (return super)
        true
      end

      private

      def array_selection(array_index)
        if @array_format == :unpacked
          array_index.map { |i| "[#{i}]" }.join
        else
          "[#{@width}*(#{vector_index(array_index)})+:#{@width}]"
        end
      end

      def vector_index(array_index)
        index = []
        array_index.zip(index_factors).reverse_each do |i, f|
          index << ((index.size.zero? && i.to_s) || "#{f}*#{i}")
        end
        index.reverse.join('+')
      end

      def index_factors
        factors = []
        @array_dimensions.reverse.inject(1) do |elements, dimension|
          factors.unshift(elements)
          elements * dimension
        end
        factors
      end
    end
  end
end
