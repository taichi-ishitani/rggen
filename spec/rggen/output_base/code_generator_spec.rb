require_relative '../../spec_helper'

module RgGen::OutputBase
  describe CodeGenerator do
    let(:context) do
      Object.new.tap do |c|
        def c.foo; 'foo' end
        def c.bar; 'bar' end
      end
    end

    let(:code) do
      double('code')
    end

    def create_generator(&body)
      CodeGenerator.new.tap(&body)
    end

    def expected_code(c)
      expect(code).to receive(:<<).with(c).ordered
    end

    describe "#generate_code" do
      context "#[]=で登録されたコード生成ブロックが指定された場合" do
        let(:generator) do
          create_generator do |g|
            g[:foo] = proc { |c| c << foo }
            g[:bar] = proc { bar }
          end
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
        end

        it "登録されたブロックをコンテキストオブジェクト上で実行し、コードを生成する" do
          generator.generate_code(context, :foo, code)
          generator.generate_code(context, :bar, code)
        end

        it "使用したコードオブジェクトを返す" do
          expect(generator.generate_code(context, :foo, code)).to be code
          expect(generator.generate_code(context, :bar, code)).to be code
        end
      end

      context "codeがnilまたは未指定の場合" do
        let(:generator) do
          create_generator do |g|
            g[:foo] = proc { |c| c << foo }
            g[:bar] = proc { bar }
          end
        end

        before do
          expect(context).to receive(:create_blank_code).twice.and_return(code)
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
        end

        it "contextの#create_blank_codeを呼び出して、空のコードオブジェクトを作ってから、コードの生成を行う" do
          generator.generate_code(context, :foo, nil)
          generator.generate_code(context, :bar)
        end

        it "生成したコードオブジェクトを返す" do
          expect(generator.generate_code(context, :foo, nil)).to be code
          expect(generator.generate_code(context, :bar     )).to be code
        end
      end

      context "#[]=で登録されたコード生成ブロックが指定されなかった場合" do
        let(:generator) do
          create_generator do |g|
            g[:foo] = proc { foo }
          end
        end

        before do
          allow(context).to receive(:create_blank_code).and_return(code)
        end

        before do
          expect(code   ).not_to receive(:<< )
          expect(context).not_to receive(:foo)
          expect(context).not_to receive(:bar)
        end

        it "何も起こらない" do
          expect {
            generator.generate_code(context, :bar, code)
          }.not_to raise_error
          expect {
            generator.generate_code(context, :bar, nil)
          }.not_to raise_error
          expect {
            generator.generate_code(context, :bar)
          }.not_to raise_error
        end

        it "使用した、または、生成したコードオブジェクトを返す" do
          expect(generator.generate_code(context, :bar, code)).to be code
          expect(generator.generate_code(context, :bar, nil )).to be code
          expect(generator.generate_code(context, :bar      )).to be code
        end
      end

      context "生成ブロックが未登録の場合" do
        let(:generator) do
          create_generator {}
        end

        before do
          allow(context).to receive(:create_blank_code).and_return(code)
        end

        before do
          expect(code   ).not_to receive(:<< )
          expect(context).not_to receive(:foo)
          expect(context).not_to receive(:bar)
        end

        it "何も起こらない" do
          expect {
            generator.generate_code(context, :foo, code)
          }.not_to raise_error
          expect {
            generator.generate_code(context, :foo, nil)
          }.not_to raise_error
          expect {
            generator.generate_code(context, :foo)
          }.not_to raise_error
        end

        it "使用した、または、生成したコードオブジェクトを返す" do
          expect(generator.generate_code(context, :foo, code)).to be code
          expect(generator.generate_code(context, :foo, nil )).to be code
          expect(generator.generate_code(context, :foo      )).to be code
        end
      end
    end

    describe "#copy" do
      let(:foo_generator) do
        create_generator { |g| g[:foo] = proc { foo }}
      end

      let(:bar_generator) do
        foo_generator.copy.tap { |g| g[:bar] = proc { bar } }
      end

      let(:baz_generator) do
        create_generator {}
      end

      let(:foobar_generator) do
        baz_generator.copy.tap do |g|
          g[:foo] = proc { foo }
          g[:bar] = proc { bar }
        end
      end

      it "CodeGeneratorのコピーを返す" do
        expect(foo_generator.copy).to be_kind_of CodeGenerator
        expect(foo_generator.copy).not_to be foo_generator
        expect(baz_generator.copy).to be_kind_of CodeGenerator
        expect(baz_generator.copy).not_to be baz_generator
      end

      specify "コピー元のコード生成ブロックを受け継ぐ" do
        expected_code 'foo'
        expected_code 'bar'
        bar_generator.generate_code(context, :foo, code)
        bar_generator.generate_code(context, :bar, code)
      end

      specify "コピー元のコード生成ブロックに影響しない" do
        expect(code).not_to receive(:<<)
        bar_generator
        foobar_generator
        foo_generator.generate_code(context, :bar, code)
        baz_generator.generate_code(context, :foo, code)
        baz_generator.generate_code(context, :bar, code)
      end
    end
  end
end
