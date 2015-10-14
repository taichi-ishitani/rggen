require_relative  '../../../spec_helper'

module RGen::Base
  describe HierarchicalStructure do
    class Test
      include HierarchicalStructure
    end

    let(:parent) do
      Test.new
    end

    let(:child) do
      Test.new(parent)
    end

    let(:grandchild) do
      Test.new(child)
    end

    describe "#parent" do
      it "親オブジェクトを返す" do
        expect(child.parent).to eql parent
      end
    end

    describe "#add_child" do
      it "子オブジェクトを#childrenの末尾に追加する" do
        parent.add_child(child)
        expect(parent.children.last).to eql child
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
  end
end
