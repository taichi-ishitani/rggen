require_relative  '../../../spec_helper'

module RGen::Base
  describe Component do
    describe "#parent" do
      it "親コンポーネントを返す" do
        parent  = Component.new
        child   = Component.new(parent)
        expect(child.parent).to eq parent
      end
    end

    describe "#append_item" do
      it "アイテムコンポーネントを、#itemsの末尾に追加する" do
        component = Component.new
        item      = Object.new
        component.append_item(item)
        expect(component.items.last).to eq item
      end
    end

    describe "#append_child" do
      it "子コンポーネントを、#childrenの末尾に追加する" do
        parent  = Component.new
        child   = Object.new
        parent.append_child(child)
        expect(parent.children.last).to eq child
      end
    end
  end
end
