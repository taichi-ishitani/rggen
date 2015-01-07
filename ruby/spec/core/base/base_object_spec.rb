require_relative  '../../spec_helper'

module RegisterGenerator::Core::Base
  describe BaseObject do
    context "親オブジェクトがない場合、" do
      it "エラーなく生成される。" do
        expect {BaseObject.new}.not_to raise_error
      end
    end

    context "親オブジェクトがある場合、" do
      describe "#parent" do
        it "親オブジェクトを返す。" do
          parent  = BaseObject.new
          child   = BaseObject.new(parent)
          expect(child.parent).to eq parent
        end
      end

      describe "#children" do
        it "子オブジェクトが末尾に追加される" do
          parent  = BaseObject.new
          child   = BaseObject.new(parent)
          expect(parent.children.last).to eq child
        end
      end
    end
  end
end
