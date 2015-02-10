require_relative  'spec_helper'

module RGen::RegisterMap
  describe GenericMap do
    let(:file) do
      "foo.csv"
    end

    let(:map) do
      GenericMap.new(file)
    end

    let(:sheet_name) do
      "foo"
    end

    let(:sheet_names) do
      ["foo", "bar"]
    end

    def match_sheet(name)
      be_kind_of(GenericMap::Sheet).and have_attributes(name: name)
    end

    describe "#[]" do
      context "引数がシート名のとき" do
        it "シート名が'sheet'のシートオブジェクトを返す" do
          sheet = map[sheet_name]
          expect(sheet).to match_sheet(sheet_name)
        end

        context "当該のシートがない場合" do
          it "新たにシートオブジェクトを追加する" do
            expect {
              sheet_names.each {|name| map[name]}
            }.to change {map.sheets}.
            from([]).
            to([match_sheet(sheet_names[0]), match_sheet(sheet_names[1])])
          end
        end

        context "当該のシートがある場合" do
          it "既存のシートオブジェクトを返す" do
            sheets  = {}
            sheet_names.each do |name|
              sheets[name]  = map[name]
            end
            sheets.each do |name, sheet|
              expect(map[name]).to eql sheet
            end
          end
        end
      end

      context "引数がインデックスのとき" do
        it "N個目のシートオブジェクトを返す" do
          sheets  = []
          sheet_names.each do |name|
            sheets  << map[name]
          end
          sheets.each_with_index do |sheet, index|
            expect(map[index]).to eql sheet
          end
        end
      end
    end
  end
end
