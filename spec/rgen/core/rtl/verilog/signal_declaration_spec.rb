require_relative '../../../../spec_helper'

module RGen::Rtl::Verilog
  describe SignalDeclaration do
    let(:type) do
      :wire
    end

    let(:name) do
      "foo"
    end

    describe "#type" do
      it "信号型を文字列で返す" do
        expect(SignalDeclaration.new(type, name).type).to eq type.to_s
      end
    end

    describe "#name" do
      it "信号名を返す" do
        expect(SignalDeclaration.new(type, name).name).to eq name
      end
    end

    describe "#width" do
      context "信号幅属性の指定が無い場合" do
        it "空文字を返す" do
          expect(SignalDeclaration.new(type, name).width).to eq ""
        end
      end

      context "信号幅属性の指定がある場合" do
        it "信号幅指定のコード片を返す" do
          [1, 2].each do |width|
            expect(SignalDeclaration.new(type, name, width: width).width).to eq "[#{width - 1}:0]"
          end
        end
      end
    end

    describe "#dimension" do
      context "配列幅属性の指定が無い場合" do
        it "空文字列を返す" do
          expect(SignalDeclaration.new(type, name).dimension).to eq ""
        end
      end

      context "配列幅属性の指定があり" do
        let(:dimension) do
          16
        end

        context "sv_enable属性の指定が無い場合" do
          it "SV形式配列幅指定のコード片を返す" do
            expect(SignalDeclaration.new(type, name, dimension: dimension).dimension).to eq "[#{dimension}]"
          end
        end

        context "sv_enable属性の指定がtrueの場合" do
          it "SV形式配列幅指定のコード片を返す" do
            expect(SignalDeclaration.new(type, name, dimension: dimension, sv_enable: true).dimension).to eq "[#{dimension}]"
          end
        end

        context "sv_enable属性の指定がfalseの場合" do
          it "Verilog形式配列幅指定のコード片を返す" do
            expect(SignalDeclaration.new(type, name, dimension: dimension, sv_enable: false).dimension).to eq "[0:#{dimension - 1}]"
          end
        end
      end
    end
  end
end
