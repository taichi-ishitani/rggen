require_relative  '../../../../spec_helper'

class RGen::RegisterMap::GenericMap
  describe Cell do
    let(:cell) do
      Cell.new("foo.csv", "bar", 0, 0)
    end

    describe "#empty?" do
      context "#valueがnilのとき" do
        it "trueを返す" do
          expect(cell).to be_empty
        end
      end

      context "#valueが文字列で空文字のとき" do
        it "trueを返す" do
          cell.value  = ""
          expect(cell).to be_empty
        end
      end

      context "#valueが文字列で空白のとき" do
        it "trueを返す" do
          cell.value  = " \n\t\r "
          expect(cell).to be_empty
        end
      end

      context "上記以外の場合" do
        it "falseを返す" do
          cell.value  = 1
          expect(cell).not_to be_empty
        end
      end
    end
  end
end
