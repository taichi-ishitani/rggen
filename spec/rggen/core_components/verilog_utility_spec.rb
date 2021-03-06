require_relative '../../spec_helper'

module RgGen
  describe VerilogUtility do
    before(:all) do
      @verilog  = Class.new {
        include VerilogUtility
      }.new
    end

    let(:verilog) do
      @verilog
    end

    describe "#assign" do
      let(:lhs) do
        VerilogUtility::Identifier.new('foo')
      end

      let(:rhs_list) do
        ["4'b0000", VerilogUtility::Identifier.new('bar')]
      end

      it "継続代入のコード片を返す" do
        expect(verilog.send(:assign, lhs,      rhs_list[0])).to eq "assign foo = 4'b0000;"
        expect(verilog.send(:assign, lhs[1,0], rhs_list[1])).to eq "assign foo[1:0] = bar;"
      end
    end

    describe "#subroutine_call" do
      it "サブルーチン呼び出しのコード片を返す" do
        expect(verilog.send(:subroutine_call, :foo               )).to eq "foo()"
        expect(verilog.send(:subroutine_call, :foo, :bar         )).to eq "foo(bar)"
        expect(verilog.send(:subroutine_call, :foo, [:bar       ])).to eq "foo(bar)"
        expect(verilog.send(:subroutine_call, :foo, [:bar, "baz"])).to eq "foo(bar, baz)"
      end
    end

    describe "#concat" do
      let(:expressions) do
        ["4'b0000", VerilogUtility::Identifier.new('foo'), VerilogUtility::Identifier.new('bar')]
      end

      it "連接のコード片を返す" do
        expect(verilog.send(:concat, expressions   )).to eq "{4'b0000, foo, bar}"
        expect(verilog.send(:concat, expressions[0])).to eq "{4'b0000}"
      end
    end

    describe "#array" do
      let(:expressions) do
        ["4'b0000", VerilogUtility::Identifier.new('foo'), VerilogUtility::Identifier.new('bar')]
      end

      it "配列リテラルのコード片を返す" do
        expect(verilog.send(:array, expressions   )).to eq "'{4'b0000, foo, bar}"
        expect(verilog.send(:array, expressions[0])).to eq "'{4'b0000}"
        expect(verilog.send(:array, []            )).to eq "'{}"
      end
    end

    describe "#bin" do
      it "与えた値をVerilog形式の2進数表記に変換する" do
        expect(verilog.send(:bin, 2, 2)).to eq "2'b10"
        expect(verilog.send(:bin, 2, 3)).to eq "3'b010"
      end
    end

    describe "#dec" do
      it "与えた値をVerilog形式の10進数表記に変換する" do
        expect(verilog.send(:dec, 8, 4)).to eq "4'd8"
      end
    end

    describe "#hex" do
      it "与えた値をVerilog形式の16進数表記に変換する" do
        expect(verilog.send(:hex, 0x1f, 7)).to eq "7'h1f"
        expect(verilog.send(:hex, 0x1f, 8)).to eq "8'h1f"
        expect(verilog.send(:hex, 0x1f, 9)).to eq "9'h01f"
      end
    end
  end
end
