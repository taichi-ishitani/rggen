require_relative  '../../spec_helper'

describe Integer do
  describe "#pow2?" do
    context "2のべき乗のとき" do
      it "真を返す" do
        [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024].each do |v|
          expect(v).to be_pow2
        end
      end
    end

    context "0のとき" do
      it "偽を返す" do
        expect(0).not_to be_pow2
      end
    end

    context "負数のとき" do
      it "偽を返す" do
        [-1, -2, -4, -8, -16, -32, -64, -128, -512, -1024].each do |v|
          expect(v).not_to be_pow2
        end
      end
    end

    context "2のべき乗でないとき" do
      it "偽を返す" do
        [3, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15].each do |v|
          expect(v).not_to be_pow2
        end
      end
    end
  end
end
