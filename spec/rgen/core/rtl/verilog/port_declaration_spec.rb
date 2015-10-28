require_relative '../../../../spec_helper'

module RGen::Rtl::Verilog
  describe PortDeclaration do
    let(:name) do
      "foo"
    end

    describe "#direction" do
      context "入出力属性の指定が無い場合" do
        it "空文字を返す" do
          expect(PortDeclaration.new(name).direction).to eq ""
        end
      end

      context "入出力属性の指定がある場合" do
        it "入出力属性を文字列で返す" do
          expect(PortDeclaration.new(name, direction: :output).direction).to eq "output"
        end
      end
    end

    describe "#type" do
      context "ポート型属性の指定が無い場合" do
        it "空文字を返す" do
          expect(PortDeclaration.new(name).type).to eq ""
        end
      end

      context "ポート型属性の指定がある場合" do
        it "ポート型を文字列で返す" do
          expect(PortDeclaration.new(name, type: :reg).type).to eq "reg"
        end
      end
    end
  end
end
