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

    def match_cell(row, column, value)
      be_kind_of(GenericMap::Cell).and have_attributes(
        value:    value,
        position: have_attributes(file: file, sheet: sheet_name, row: row, column: column)
      )
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

    describe "#[]=" do
      let(:old_values) do
        [
          [0, 1],
          [2, 3]
        ]
      end

      let(:new_values) do
        [
          [4, 5   ],
          [6      ],
          [7, 8, 9]
        ]
      end

      before do
        map[sheet_name][0, 0] = old_values[0][0]
        map[sheet_name][0, 1] = old_values[0][1]
        map[sheet_name][1, 0] = old_values[1][0]
        map[sheet_name][1, 1] = old_values[1][1]
      end

      it "シート名が'sheet'のシートオブジェクトの内容を右辺値の内容で置き換える" do
        expect {
          map[sheet_name] = new_values
        }.to change{map[sheet_name].rows}.
        from([
          [match_cell(0, 0, old_values[0][0]), match_cell(0, 1, old_values[0][1])],
          [match_cell(1, 0, old_values[1][0]), match_cell(1, 1, old_values[1][1])]
        ]).
        to([
          [match_cell(0, 0, new_values[0][0]), match_cell(0, 1, new_values[0][1])                                    ],
          [match_cell(1, 0, new_values[1][0])                                                                        ],
          [match_cell(2, 0, new_values[2][0]), match_cell(2, 1, new_values[2][1]), match_cell(2, 2, new_values[2][2])]
        ])
      end
    end
  end
end
