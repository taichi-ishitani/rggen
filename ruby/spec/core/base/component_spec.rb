require_relative  '../../spec_helper'

module RegisterGenerator::Base
  describe Component do
    describe "#initialize" do
      context "親コンポーネントがない場合、" do
        it "エラー無く生成される" do
          expect{Component.new}.not_to raise_error
        end
      end

      context "親コンポーネントが与えられた場合、" do
        it "自身を引数として、親コンポーネントの#append_childを呼び出す" do
          parent  = Component.new
          allow(parent).to receive(:append_child)

          child = Component.new(parent)
          expect(parent).to have_received(:append_child).with(child)
        end
      end
    end

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
