require_relative '../../spec_helper'

module RGen::OutputBase
  describe Line do
    let(:line) do
      Line.new
    end

    describe "#empty?" do
      context "#<<で単語の追加が行われなかった場合" do
        it "真を返す" do
          expect(line).to be_empty
        end
      end

      context "#<<で空文字が追加された場合" do
        before do
          line << '' << ''
        end

        it "真を返す" do
          expect(line).to be_empty
        end
      end

      context "#<<で空文字以外が追加された場合" do
        before do
          line << '' << 'foo'
        end

        it "偽を返す" do
          expect(line).not_to be_empty
        end
      end
    end

    describe "#to_s" do
      it "#<<で追加された単語を連結した文字列を返す" do
        line << 'foo'
        line << :bar
        line << 1
        expect(line.to_s).to eq "foobar1"
      end

      context "#indent=でインデント幅が設定されている場合" do
        before do
          line << 'foo'
          line << 'bar'
          line.indent = 2
        end

        it "#indent=で設定された個数の空白を行頭に付加する" do
          expect(line.to_s).to eq "  foobar"
        end
      end

      context "#indent=でインデント幅が設定されていて、#<<で単語が追加されていない場合" do
        before do
          line.indent = 2
        end

        it "空文字を返す" do
          expect(line.to_s).to eq ''
        end
      end
    end
  end
end
