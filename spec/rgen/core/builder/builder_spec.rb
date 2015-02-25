require_relative  '../../../spec_helper'

module RGen::Builder
  describe Builder do
    let(:builder) do
      Builder.new
    end

    it "4種類のカテゴリを持つ" do
      expect(builder.categories).to match(
        global:         be_kind_of(Category),
        register_block: be_kind_of(Category),
        register:       be_kind_of(Category),
        bit_field:      be_kind_of(Category)
      )
    end
  end
end
