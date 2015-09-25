require_relative  '../../../spec_helper'

module RGen::Base
  describe Component do
    describe "#parent" do
      it "親コンポーネントを返す" do
        parent  = Component.new
        child   = Component.new(parent)
        expect(child.parent).to eql parent
      end
    end

    describe "#add_item" do
      it "アイテムコンポーネントを、#itemsの末尾に追加する" do
        component = Component.new
        item      = Object.new
        component.add_item(item)
        expect(component.items.last).to eql item
      end
    end

    describe "#add_child" do
      it "子コンポーネントを、#childrenの末尾に追加する" do
        parent  = Component.new
        child   = Object.new
        parent.add_child(child)
        expect(parent.children.last).to eql child
      end
    end
  end
end
