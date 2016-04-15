require_relative '../../spec_helper'

module RgGen::OutputBase
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
      let(:code) do
        test_object.send(:code_block) do |buffer|
          buffer << 'foo' << :newline
          test_object.send(:indent, buffer, 2) do
            buffer << 'foo' << :newline
            buffer << '     ' << :newline
            buffer << '  foo' << :newline
          end
          buffer << 'foo'
          test_object.send(:indent, buffer, 2) do
            buffer << 'foo'
          end
          buffer << 'foo' << :newline
        end
      end

      let(:expected_code) do
        <<'CODE'
foo
  foo

    foo
foo
  foo
foo
CODE
      end

      it "ブロック内で入力されたコードに、指定した幅でインデントを行う" do
        expect(code.to_s).to eq expected_code
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
