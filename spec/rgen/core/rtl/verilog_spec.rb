require_relative '../../../spec_helper'

module RGen::Rtl
  describe Verilog do
    before(:all) do
      @verilog  = Class.new {
        include Verilog
      }.new
    end

    let(:name) do
      'foo'
    end

    describe "#wire" do
      it "引数で与えた変数名のIdentifierオブジェクトを返す" do
        identifier  = @verilog.send(:wire, name)[0]
        expect(identifier     ).to be_instance_of Verilog::Identifier
        expect(identifier.to_s).to eq name
      end

      it "#typeが:wireのSignalDeclarationオブジェクトを返す" do
        declaration = @verilog.send(:wire, name)[1]
        expect(declaration     ).to be_instance_of Verilog::SignalDeclaration
        expect(declaration.name).to eq name
        expect(declaration.type).to eq :wire
      end

      context "属性を与えた場合" do
        it "与えた属性を持つSignalDeclarationオブジェクトを返す" do
          declaration = @verilog.send(:wire, name, width: 2, dimension: 4, sv_enable: false)[1]
          expect(declaration.width    ).to eq "[1:0]"
          expect(declaration.dimension).to eq "[0:3]"
        end
      end
    end

    describe "#reg" do
      it "引数で与えた変数名のIdentifierオブジェクトを返す" do
        identifier  = @verilog.send(:reg, name)[0]
        expect(identifier     ).to be_instance_of Verilog::Identifier
        expect(identifier.to_s).to eq name
      end

      it "#typeが:regのSignalDeclarationオブジェクトを返す" do
        declaration = @verilog.send(:reg, name)[1]
        expect(declaration     ).to be_instance_of Verilog::SignalDeclaration
        expect(declaration.name).to eq name
        expect(declaration.type).to eq :reg
      end

      context "属性を与えた場合" do
        it "与えた属性を持つSignalDeclarationオブジェクトを返す" do
          declaration = @verilog.send(:reg, name, width: 2, dimension: 4, sv_enable: false)[1]
          expect(declaration.width    ).to eq "[1:0]"
          expect(declaration.dimension).to eq "[0:3]"
        end
      end
    end

    describe "#logic" do
      it "引数で与えた変数名のIdentifierオブジェクトを返す" do
        identifier  = @verilog.send(:logic, name)[0]
        expect(identifier     ).to be_instance_of Verilog::Identifier
        expect(identifier.to_s).to eq name
      end

      it "#typeが:logicのSignalDeclarationオブジェクトを返す" do
        declaration = @verilog.send(:logic, name)[1]
        expect(declaration     ).to be_instance_of Verilog::SignalDeclaration
        expect(declaration.name).to eq name
        expect(declaration.type).to eq :logic
      end

      context "属性を与えた場合" do
        it "与えた属性を持つSignalDeclarationオブジェクトを返す" do
          declaration = @verilog.send(:logic, name, width: 2, dimension: 4, sv_enable: false)[1]
          expect(declaration.width    ).to eq "[1:0]"
          expect(declaration.dimension).to eq "[0:3]"
        end
      end
    end

    describe "#input" do
      it "引数で与えたポート名のIdentifierオブジェクトを返す" do
        identifier  = @verilog.send(:input, name)[0]
        expect(identifier     ).to be_instance_of Verilog::Identifier
        expect(identifier.to_s).to eq name
      end

      it "#directionが:inputのPortDeclarationオブジェクトを返す" do
        declaration = @verilog.send(:input, name)[1]
        expect(declaration          ).to be_instance_of Verilog::PortDeclaration
        expect(declaration.name     ).to eq name
        expect(declaration.direction).to eq :input
      end

      context "属性を与えた場合" do
        it "与えた属性を持つPortDeclarationオブジェクトを返す" do
          declaration = @verilog.send(:input, name, width: 2, type: :logic, dimension: 4)[1]
          expect(declaration.width    ).to eq "[1:0]"
          expect(declaration.type     ).to eq :logic
          expect(declaration.dimension).to eq "[4]"
        end
      end
    end

    describe "#output" do
      it "引数で与えたポート名のIdentifierオブジェクトを返す" do
        identifier  = @verilog.send(:output, name)[0]
        expect(identifier     ).to be_instance_of Verilog::Identifier
        expect(identifier.to_s).to eq name
      end

      it "#directionが:outputのPortDeclarationオブジェクトを返す" do
        declaration = @verilog.send(:output, name)[1]
        expect(declaration          ).to be_instance_of Verilog::PortDeclaration
        expect(declaration.name     ).to eq name
        expect(declaration.direction).to eq :output
      end

      context "属性を与えた場合" do
        it "与えた属性を持つPortDeclarationオブジェクトを返す" do
          declaration = @verilog.send(:output, name, width: 2, type: :logic, dimension: 4)[1]
          expect(declaration.width    ).to eq "[1:0]"
          expect(declaration.type     ).to eq :logic
          expect(declaration.dimension).to eq "[4]"
        end
      end
    end

    describe "#parameter" do
      it "引数で与えたポート名のIdentifierオブジェクトを返す" do
        identifier  = @verilog.send(:parameter, name, 1)[0]
        expect(identifier     ).to be_instance_of Verilog::Identifier
        expect(identifier.to_s).to eq name
      end

      it "#typeに:parameterと引数で与えた属性持つParameterDeclarationオブジェクトを返す" do
        declaration = @verilog.send(:parameter, name, 1)[1]
        expect(declaration              ).to be_instance_of Verilog::ParameterDeclaration
        expect(declaration.name         ).to eq name
        expect(declaration.type         ).to eq :parameter
        expect(declaration.default_value).to eq 1
      end
    end

    describe "#localparam" do
      it "引数で与えたポート名のIdentifierオブジェクトを返す" do
        identifier  = @verilog.send(:localparam, name, 1)[0]
        expect(identifier     ).to be_instance_of Verilog::Identifier
        expect(identifier.to_s).to eq name
      end

      it "#typeに:localparamと引数で与えた属性持つParameterDeclarationオブジェクトを返す" do
        declaration = @verilog.send(:localparam, name, 1)[1]
        expect(declaration              ).to be_instance_of Verilog::ParameterDeclaration
        expect(declaration.name         ).to eq name
        expect(declaration.type         ).to eq :localparam
        expect(declaration.default_value).to eq 1
      end
    end

    describe "#assign" do
      let(:lhs) do
        Verilog::Identifier.new(name)
      end

      let(:rhs_list) do
        ["4'b0000", Verilog::Identifier.new('bar')]
      end

      it "継続代入のコード片を返す" do
        expect(@verilog.send(:assign, lhs,      rhs_list[0])).to eq "assign foo = 4'b0000;"
        expect(@verilog.send(:assign, lhs[1,0], rhs_list[1])).to eq "assign foo[1:0] = bar;"
      end
    end

    describe "#concat" do
      let(:expressions) do
        ["4'b0000", Verilog::Identifier.new('foo'), Verilog::Identifier.new('bar')]
      end

      it "連接のコード片を返す" do
        expect(@verilog.send(:concat, *expressions  )).to eq "{4'b0000, foo, bar}"
        expect(@verilog.send(:concat, expressions[0])).to eq "{4'b0000}"
      end
    end

    describe "#bin" do
      it "与えた値をVerilog形式の2進数表記に変換する" do
        expect(@verilog.send(:bin, 2, 2)).to eq "2'b10"
        expect(@verilog.send(:bin, 2, 3)).to eq "3'b010"
      end
    end

    describe "#dec" do
      it "与えた値をVerilog形式の10進数表記に変換する" do
        expect(@verilog.send(:dec, 8, 4)).to eq "4'd8"
      end
    end

    describe "#hex" do
      it "与えた値をVerilog形式の16進数表記に変換する" do
        expect(@verilog.send(:hex, 0x1f, 7)).to eq "7'h1f"
        expect(@verilog.send(:hex, 0x1f, 8)).to eq "8'h1f"
        expect(@verilog.send(:hex, 0x1f, 9)).to eq "9'h01f"
      end
    end
  end
end
