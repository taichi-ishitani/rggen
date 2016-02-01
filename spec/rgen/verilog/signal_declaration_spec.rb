require_relative '../../spec_helper'

module RGen::Verilog
  describe SignalDeclaration do
    let(:name) do
      "foo"
    end

    describe "#name" do
      it "信号名を返す" do
        expect(SignalDeclaration.new(name).name).to eq name
      end
    end

    describe "#type" do
      context "信号型属性の指定が無い場合" do
        it "空文字を返す" do
          expect(SignalDeclaration.new(name).type).to eq ""
        end
      end

      context "信号型属性の指定がある場合" do
        it "信号型を返す" do
          expect(SignalDeclaration.new(name, type: :reg).type).to eq :reg
        end
      end
    end

    describe "#width" do
      context "信号幅属性の指定が無い場合" do
        it "空文字を返す" do
          expect(SignalDeclaration.new(name).width).to eq ""
        end
      end

      context "信号幅属性が1ビットの場合" do
        it "空文字を返す" do
          expect(SignalDeclaration.new(name, width: 1).width).to eq ""
        end
      end

      context "信号幅属性の2ビット以上の場合" do
        it "信号幅指定のコード片を返す" do
          [2, 3].each do |width|
            expect(SignalDeclaration.new(name, width: width).width).to eq "[#{width - 1}:0]"
          end
        end
      end
    end

    describe "#dimensions" do
      context "配列幅属性の指定が無い場合" do
        it "空文字列を返す" do
          expect(SignalDeclaration.new(name).dimensions).to eq ""
        end
      end

      context "配列属性がnilの場合" do
        it "空文字列を返す" do
          expect(SignalDeclaration.new(name, dimensions: nil).dimensions).to eq ""
        end
      end

      context "配列幅属性の指定がありで" do
        context "sv_enable属性の指定が無い場合" do
          it "SV形式配列幅指定のコード片を返す" do
            expect(SignalDeclaration.new(name, dimensions: [2    ]).dimensions).to eq "[2]"
            expect(SignalDeclaration.new(name, dimensions: [2, 16]).dimensions).to eq "[2][16]"
          end
        end

        context "sv_enable属性の指定がtrueの場合" do
          it "SV形式配列幅指定のコード片を返す" do
            expect(SignalDeclaration.new(name, dimensions: [2    ], sv_enable: true).dimensions).to eq "[2]"
            expect(SignalDeclaration.new(name, dimensions: [2, 16], sv_enable: true).dimensions).to eq "[2][16]"
          end
        end

        context "sv_enable属性の指定がfalseの場合" do
          it "Verilog形式配列幅指定のコード片を返す" do
            expect(SignalDeclaration.new(name, dimensions: [2    ], sv_enable: false).dimensions).to eq "[0:1]"
            expect(SignalDeclaration.new(name, dimensions: [2, 16], sv_enable: false).dimensions).to eq "[0:1][0:15]"
          end
        end
      end
    end
  end
end
