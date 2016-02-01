require_relative '../../spec_helper'

module RGen::Verilog
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
        it "入出力属性を返す" do
          expect(PortDeclaration.new(name, direction: :output).direction).to eq :output
        end
      end
    end
  end
end
