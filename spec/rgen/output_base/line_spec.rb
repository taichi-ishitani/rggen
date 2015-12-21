require_relative '../../spec_helper'

module RGen::OutputBase
  describe Line do
    before do
      line << 'foo'
      line << :bar
    end

    let(:line) do
      Line.new
    end

    describe "#to_s" do
      it "#<<で追加された単語を連結した文字列を返す" do
        expect(line.to_s).to eq "foobar"
      end

      context "#indent=でインデント幅が設定されている場合" do
        before do
          line.indent = 2
        end

        it "#indent=で設定された個数の空白を行頭に付加する" do
          expect(line.to_s).to eq "  foobar"
        end
      end
    end
  end
end
