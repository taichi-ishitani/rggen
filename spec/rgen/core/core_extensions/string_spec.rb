require_relative  '../../../spec_helper'

describe String do
  describe "#verilog_identifer?" do
    context "Verilogの識別子として使えるとき" do
      let(:valid_strings) do
        ["a", "A", "_", "a0", "a$", "a0$", "a$0", "foo", "foo_bar"]
      end

      it "真を返す" do
        expect(valid_strings).to be_all(&:verilog_identifer?)
      end
    end

    context "Verilogの識別子として使えないとき" do
      let(:invalid_strings) do
        ["0foo", "$foo", "foo?", "foo bar", "foo\nbar", "foo\n"]
      end

      it "偽を返す" do
        expect(invalid_strings).to be_none(&:verilog_identifer?)
      end
    end
  end
end
