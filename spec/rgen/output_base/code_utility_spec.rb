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

    describe "#code_block" do
      it "CodeBlockオブジェクトを返す" do
        expect(test_object.send(:code_block)).to be_a_kind_of(CodeBlock)
      end

      context "ブロックが与えられた場合" do
        let(:code) do
          test_object.send(:code_block) do |buffer|
            buffer << 'foo' << :newline
            buffer << 'bar'
          end
        end

        it "ブロック内で入力されたコードを含んだCodeBlockオブジェクトを返す" do
          expect(code.to_s).to eq "foo\nbar"
        end
      end

      context "インデント幅が指定された場合" do
        let(:code) do
          test_object.send(:code_block, 2) do |buffer|
            buffer << 'foo' << :newline
            buffer << "bar\n  baz"
          end
        end

        it "指定した幅でインデントされたCodeBlockオブジェクトを返す" do
          expect(code.to_s).to eq "  foo\n  bar\n    baz"
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

      it "ブロック内で入力されたコードに、sizeで指定されたインデントされたCodeBlockオブジェクトとして返す" do
        output  = test_object.send(:indent, 2) do |buf|
          buf << :foo       << :newline
          buf << '  bar'    << :newline
          buf               << :newline
          buf << "  \t"     << :newline
          buf << "bar\nbaz" << :newline
        end
        expect(output).to be_a_kind_of(CodeBlock)
        expect(output.to_s).to eq expected_code
      end
    end

    describe "#loop_index" do
      it "ネストの深さに応じたループ変数名を返す" do
        expect(test_object.send(:loop_index, 0)).to eq "i"
        expect(test_object.send(:loop_index, 1)).to eq "j"
        expect(test_object.send(:loop_index, 2)).to eq "k"
        expect(test_object.send(:loop_index, 3)).to eq "l"
      end
    end
  end
end
