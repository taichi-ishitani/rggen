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
  end
end
