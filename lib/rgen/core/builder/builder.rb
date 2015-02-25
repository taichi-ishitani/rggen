module RGen::Builder
  class Builder
    INITIAL_CATEGORIES  = [
      :global,
      :register_block,
      :register,
      :bit_field
    ].freeze

    def initialize
      @categories = INITIAL_CATEGORIES.each_with_object({}) do |category, hash|
        hash[category]  = Category.new
      end
    end

    attr_reader :categories
  end
end
