require_relative  '../../../spec_helper'

module RGen::Base
  describe Component do
    describe "#add_item" do
      it "アイテムコンポーネントを、#itemsの末尾に追加する" do
        component = Component.new
        item      = Object.new
        component.add_item(item)
        expect(component.items.last).to eql item
      end
    end
  end
end
