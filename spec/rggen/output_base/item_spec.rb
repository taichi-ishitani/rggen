require_relative '../../spec_helper'

module RgGen::OutputBase
  describe Item do
    let(:configuration) do
      RgGen::InputBase::Component.new(nil)
    end

    let(:register_map) do
      RgGen::InputBase::Component.new(nil)
    end

    let(:component) do
      Component.new(nil, configuration, register_map)
    end

    let(:code) do
      double('code')
    end

    def define_item(base = Item, &body)
      Class.new(base, &body).new(component).tap { |item| component.add_item(item)}
    end

    def expected_code(c)
      expect(code).to receive(:<<).with(c).ordered
    end

    def expected_file_out(p, c)
      expect(File).to receive(:write).with(p, c, nil, binmode: true).ordered
    end

    describe "#build" do
      context ".buildでブロックが与えられた場合" do
        let(:item) do
          define_item do
            attr_reader :foo
            build { @foo  = object_id }
          end
        end

        it "登録されたブロックをアイテムのコンテキストで実行する" do
          item.build
          expect(item.foo).to eq item.object_id
        end

        context "継承されたとき" do
          let(:child_item) do
            define_item(item.class) do
              attr_reader :bar
              build { @bar  = object_id }
            end
          end

          let(:grandchild_item) do
            define_item(child_item.class) {}
          end

          specify "登録されたブロックが継承先に引き継がれる" do
            grandchild_item.build
            expect(grandchild_item.foo).to eq grandchild_item.object_id
            expect(grandchild_item.bar).to eq grandchild_item.object_id
          end
        end
      end
    end

    describe "#generate_pre_code" do
      context ".generate_pre_codeで登録されたコード生成ブロックの種類が指定された場合" do
        let(:foo_item) do
          define_item { generate_pre_code(:foo) { |c| c << 'foo' } }
        end

        let(:bar_item) do
          define_item { generate_pre_code(:bar) { 'bar' } }
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
        end

        it "指定されたコード生成ブロックを実行する" do
          foo_item.generate_pre_code(:foo, code)
          bar_item.generate_pre_code(:bar, code)
        end
      end

      context ".generate_pre_codeで複数回コード生成が登録された場合" do
        let(:item) do
          define_item do
            generate_pre_code(:foo) { 'foo' }
            generate_pre_code(:bar) { 'bar' }
            generate_pre_code(:baz) { 'baz' }
          end
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
          expect(code).not_to receive(:<<).with('baz')
        end

        it "指定された種類のコード生成ブロックを実行する" do
          item.generate_pre_code(:foo, code)
          item.generate_pre_code(:bar, code)
        end
      end

      context ".generate_pre_codeで登録されていないコード生成の種類が指定された場合" do
        let(:item) do
          define_item { generate_pre_code(:foo) { 'foo' } }
        end

        before do
          expect(code).not_to receive(:<<)
        end

        it "何も起こらない" do
          expect {
            item.generate_pre_code(:bar, code)
          }.not_to raise_error
        end
      end

      context "継承されたとき" do
        let(:item) do
          define_item { generate_pre_code(:foo) { 'foo' } }
        end

        let(:child_item) do
          define_item(item.class) { generate_pre_code(:bar) { 'bar' } }
        end

        let(:grandchild_item) do
          define_item(child_item.class) {}
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
        end

        specify "登録されたコード生成ブロックが継承先に引き継がれる" do
          grandchild_item.generate_pre_code(:foo, code)
          grandchild_item.generate_pre_code(:bar, code)
        end
      end

      context "継承先で同名のコード生成ブロックが登録された場合" do
        let(:item) do
          define_item { generate_pre_code(:foo) { 'foo' } }
        end

        let(:child_item) do
          define_item(item.class) { generate_pre_code(:foo) { 'bar' } }
        end

        specify "新しいコード生成ブロックで上書きされる" do
          expected_code 'bar'
          child_item.generate_pre_code(:foo, code)
        end

        specify "親クラスの生成ブロックは上書きされない" do
          expected_code 'foo'
          item.generate_pre_code(:foo, code)
        end
      end
    end

    describe "#generate_code" do
      context ".generate_codeで登録されたコード生成ブロックの種類が指定された場合" do
        let(:foo_item) do
          define_item {  generate_code(:foo) { |c| c << 'foo' } }
        end

        let(:bar_item) do
          define_item {  generate_code(:bar) { 'bar' } }
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
        end

        it "指定されたコード生成ブロックを実行する" do
          foo_item.generate_code(:foo, code)
          bar_item.generate_code(:bar, code)
        end
      end

      context ".generate_codeで複数回コード生成が登録された場合" do
        let(:item) do
          define_item do
            generate_code(:foo) { 'foo' }
            generate_code(:bar) { 'bar' }
            generate_code(:baz) { 'baz' }
          end
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
          expect(code).not_to receive(:<<).with('baz')
        end

        it "指定された種類のコード生成ブロックを実行する" do
          item.generate_code(:foo, code)
          item.generate_code(:bar, code)
        end
      end

      context ".generate_codeで登録されていないコード生成の種類が指定された場合" do
        let(:item) do
          define_item { generate_code(:foo) { 'foo' } }
        end

        before do
          expect(code).not_to receive(:<<)
        end

        it "何も起こらない" do
          expect {
            item.generate_code(:bar, code)
          }.not_to raise_error
        end
      end

      context "継承されたとき" do
        let(:item) do
          define_item { generate_code(:foo) { 'foo' } }
        end

        let(:child_item) do
          define_item(item.class) { generate_code(:bar) { 'bar' } }
        end

        let(:grandchild_item) do
          define_item(child_item.class) {}
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
        end

        specify "登録されたコード生成ブロックが継承先に引き継がれる" do
          grandchild_item.generate_code(:foo, code)
          grandchild_item.generate_code(:bar, code)
        end
      end

      context "継承先で同名のコード生成ブロックが登録された場合" do
        let(:item) do
          define_item { generate_code(:foo) { 'foo' } }
        end

        let(:child_item) do
          define_item(item.class) { generate_code(:foo) { 'bar' } }
        end

        specify "新しいコード生成ブロックで上書きされる" do
          expected_code 'bar'
          child_item.generate_code(:foo, code)
        end

        specify "親クラスの生成ブロックは上書きされない" do
          expected_code 'foo'
          item.generate_code(:foo, code)
        end
      end
    end

    describe "#generate_post_code" do
      context ".generate_post_codeで登録されたコード生成ブロックの種類が指定された場合" do
        let(:foo_item) do
          define_item {  generate_post_code(:foo) { |c| c << 'foo' } }
        end

        let(:bar_item) do
          define_item {  generate_post_code(:bar) { 'bar' } }
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
        end

        it "指定されたコード生成ブロックを実行する" do
          foo_item.generate_post_code(:foo, code)
          bar_item.generate_post_code(:bar, code)
        end
      end

      context ".generate_post_codeで複数回コード生成が登録された場合" do
        let(:item) do
          define_item do
            generate_post_code(:foo) { 'foo' }
            generate_post_code(:bar) { 'bar' }
            generate_post_code(:baz) { 'baz' }
          end
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
          expect(code).not_to receive(:<<).with('baz')
        end

        it "指定された種類のコード生成ブロックを実行する" do
          item.generate_post_code(:foo, code)
          item.generate_post_code(:bar, code)
        end
      end

      context ".generate_post_codeで登録されていないコード生成の種類が指定された場合" do
        let(:item) do
          define_item { generate_post_code(:foo) { 'foo' } }
        end

        before do
          expect(code).not_to receive(:<<)
        end

        it "何も起こらない" do
          expect {
            item.generate_post_code(:bar, code)
          }.not_to raise_error
        end
      end

      context "継承されたとき" do
        let(:item) do
          define_item { generate_post_code(:foo) { 'foo' } }
        end

        let(:child_item) do
          define_item(item.class) { generate_post_code(:bar) { 'bar' } }
        end

        let(:grandchild_item) do
          define_item(child_item.class) {}
        end

        before do
          expected_code 'foo'
          expected_code 'bar'
        end

        specify "登録されたコード生成ブロックが継承先に引き継がれる" do
          grandchild_item.generate_post_code(:foo, code)
          grandchild_item.generate_post_code(:bar, code)
        end
      end

      context "継承先で同名のコード生成ブロックが登録された場合" do
        let(:item) do
          define_item { generate_post_code(:foo) { 'foo' } }
        end

        let(:child_item) do
          define_item(item.class) { generate_post_code(:foo) { 'bar' } }
        end

        specify "新しいコード生成ブロックで上書きされる" do
          expected_code 'bar'
          child_item.generate_post_code(:foo, code)
        end

        specify "親クラスの生成ブロックは上書きされない" do
          expected_code 'foo'
          item.generate_post_code(:foo, code)
        end
      end
    end

    describe "#write_file" do
      let(:foo_item) do
        define_item do
          write_file '<%= name %>.foo' do
            'foo'
          end

          def name
            'foo'
          end
        end
      end

      let(:bar_item) do
        define_item do
          write_file '<%= name %>.bar' do |pathname|
            File.join(pathname.dirname, pathname.basename)
          end

          def name
            'bar'
          end
        end
      end

      let(:baz_item) do
        define_item do
          write_file '<%= name %>.baz' do |pathname, code|
            code << pathname
          end

          def name
            'baz'
          end
        end
      end

      it ".write_fileで登録されたブロックの実行結果を、指定されたパターンのファイル名で書き出す" do
        expected_file_out 'foo.foo', 'foo'
        expected_file_out 'bar.bar', './bar.bar'
        expected_file_out 'baz.baz', 'baz.baz'
        foo_item.write_file
        bar_item.write_file
        baz_item.write_file
      end

      context "出力ディレクトリの指定がある場合" do
        let(:output_directory) do
          'qux'
        end

        it "指定されたディレクトリにファイルを書き出す" do
          expected_file_out 'qux/foo.foo', 'foo'
          expected_file_out 'qux/bar.bar', 'qux/bar.bar'
          expected_file_out 'qux/baz.baz', 'qux/baz.baz'
          foo_item.write_file(output_directory)
          bar_item.write_file(output_directory)
          baz_item.write_file(output_directory)
        end
      end

      context ".write_fileで生成ブロックが登録されていない場合" do
        let(:item) do
          define_item {}
        end

        it "何も起こらない" do
          expect {
            item.write_file
          }.not_to raise_error
        end
      end
    end

    describe "#exported_methods" do
      let(:item) do
        define_item do
          export :foo
          export :bar, :baz
        end
      end

      let(:child_item) do
        define_item(item.class) { export :qux }
      end

      let(:grandchild_item) do
        define_item(child_item.class) { export :quux }
      end

      it ".exportで登録されたメソッド名一覧を返す" do
        expect(item.exported_methods).to match [:foo, :bar, :baz]
      end

      specify "継承元のメソッド名一覧を引き継ぐ" do
        expect(     child_item.exported_methods).to match [:foo, :bar, :baz, :qux       ]
        expect(grandchild_item.exported_methods).to match [:foo, :bar, :baz, :qux, :quux]
      end
    end
  end
end
