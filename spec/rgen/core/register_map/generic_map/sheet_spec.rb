require_relative  '../spec_helper'

class RGen::RegisterMap::GenericMap
  describe Sheet do
    let(:file) do
      "foo.csv"
    end

    let(:name) do
      "foo"
    end

    let(:sheet) do
      Sheet.new(file, name)
    end

    let(:positions) do
      [[0, 0], [0, 1], [1, 0], [1, 1]]
    end

    let(:values) do
      [[0, 0, :foo], [0, 1, :bar], [1, 0, :baz], [1, 1, :qux]]
    end

    def match_cell(row, column, value = nil)
      be_kind_of(RGen::RegisterMap::GenericMap::Cell).and have_attributes(
        value:    value,
        position: have_attributes(file: file, sheet: name, row: row, column: column)
      )
    end

    describe "#[]" do
      it "[row, column]の場所のセルオブジェクトを返す" do
        positions.each do |row, column|
          expect(sheet[row, column]).to match_cell(row, column)
        end
      end

      context "[row, column]の場所にセルオブジェクトがない場合" do
        it "その場所に新たにセルオブジェクトを追加する" do
          expect {
            positions.each {|row, column| sheet[row, column]}
          }.to change{sheet.rows}.
          from([]).
          to([
            [match_cell(*positions[0]), match_cell(*positions[1])],
            [match_cell(*positions[2]), match_cell(*positions[3])]
          ])
        end
      end

      context "[row, column]の場所にセルオブジェクトがある場合" do
        it "既存のオブジェクトを返す" do
          cells = []
          positions.each {|row, column| cells << sheet[row, column]}

          positions.each_with_index do |(row, column), index|
            expect(sheet[row, column]).to eql cells[index]
          end
        end
      end
    end

    describe "#[]=" do
      it "[row, column]の場所のセルにvalueをセットする" do
        values.each do |row, column, value|
          expect{
            sheet[row, column]  = value
          }.to change{sheet[row, column].value}.from(nil).to(value)
        end
      end
    end
  end
end
