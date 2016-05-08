require_relative  '../../spec_helper'

module RgGen::Base
  describe Component do
    let(:component) do
      Component.new(nil)
    end

    let(:parent) do
      Component.new(nil)
    end

    let(:child) do
      Component.new(parent)
    end

    let(:grandchild) do
      Component.new(child)
    end

    let(:item) do
      Object.new
    end

    describe "#parent" do
      it "親オブジェクトを返す" do
        expect(child.parent).to eql parent
      end
    end

    describe "#need_children?" do
      it "子コンポーネントが必要かどうかを返す" do
        parent.instance_variable_set(:@need_children, true)
        expect(parent.need_children?).to be true
        parent.instance_variable_set(:@need_children, false)
        expect(parent.need_children?).to be false
      end
    end

    describe "#add_child" do
      context "子コンポーネントを必要とする場合" do
        before do
          parent.instance_variable_set(:@need_children, true)
        end

        it "子オブジェクトを#childrenの末尾に追加する" do
          parent.add_child(child)
          expect(parent.children.last).to eql child
        end
      end

      context "子コンポーネントを必要としない場合" do
        before do
          parent.instance_variable_set(:@need_children, false)
        end

        it "子コンポーネントの追加を行わない" do
          expect {
            parent.add_child(child)
          }.not_to change { parent.children }
        end
      end
    end

    describe "#level" do
      context "親オブジェクトがない場合" do
        it "0を返す" do
          expect(parent.level).to eq 0
        end
      end

      context "親オブジェクトがある場合" do
        it "parent.level + 1を返す" do
          expect(child.level     ).to eq 1
          expect(grandchild.level).to eq 2
        end
      end
    end

    describe "#add_item" do
      it "アイテムコンポーネントを、#itemsの末尾に追加する" do
        component.add_item(item)
        expect(component.items.last).to eql item
      end
    end
  end
end
