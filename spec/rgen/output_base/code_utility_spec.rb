require_relative '../../spec_helper'

module RGen::OutputBase
  describe CodeUtility do
    before(:all) do
      @test_object  = Class.new {
        include CodeUtility
      }.new
    end

    let(:test_object) do
      @test_object
    end

    describe "#space" do
      context "引数ないとき" do
        it "空白を1つ返す" do
          expect(test_object.send(:space)).to eq ' '
        end
      end

      context "正数が与えられた場合" do
        it "与えた幅分の空白を返す" do
          expect(test_object.send(:space, 3)).to eq '   '
        end
      end
    end

    describe "#indent" do
      let(:expected_code) do
        <<'CODE'
  foo
    bar


  bar
  baz
CODE
      end

      it "ブロック内で入力されたコードに、sizeで指定されたインデントを付けて1つの文字列として返す" do
        output  = test_object.send(:indent, 2) do |buf|
          buf << :foo       << "\n"
          buf << '  bar'    << "\n"
          buf               << "\n"
          buf << "  \t"     << "\n"
          buf << "bar\nbaz" << "\n"
        end
        expect(output).to eq expected_code
      end
    end
  end
end
