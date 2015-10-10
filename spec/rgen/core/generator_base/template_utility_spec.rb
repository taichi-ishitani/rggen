require_relative '../../../spec_helper'

module RGen::GeneratorBase
  describe TemplateUtility do
    def set_template_contents(template_contents)
      template_contents.each do |path, contents|
        expect(File).to receive(:read).with(path).once.and_return(contents)
      end
    end

    let(:test_class) do
      Class.new do
        include TemplateUtility

        def initialize(v)
          @v  = v
        end

        def foo_bar
          "#{@v} foo_bar"
        end

        def baz_qux
          "#{@v} baz_qux"
        end
      end
    end

    let(:object) do
      test_class.new(0)
    end

    describe "#process_template" do
      it "テンプレートをレシーバのコンテキストで処理する" do
        path  = 'foo.erb'
        set_template_contents(path => '<%= object_id %>')
        expect(object.process_template(path)).to eq object.object_id.to_s
      end

      context "テンプレートのパスがされた場合" do
        before do
          set_template_contents(path => contents)
        end

        let(:path) do
          'foo/bar.erb'
        end

        let(:contents) do
          '<%= foo_bar %>'
        end

        it "指定されたテンプレートの処理結果を返す" do
          expect(object.process_template(path)).to eq object.foo_bar
        end
      end

      context "テンプレートのパスが指定されなかった場合" do
        before do
          set_template_contents(path => contents)
        end

        let(:path) do
          File.ext(File.expand_path(__FILE__), '.erb')
        end

        let(:contents) do
          '<%= baz_qux %>'
        end

        it "実行元のファイルパスの拡張子を'erb'に変更したものをテンプレートのパスとして処理する" do
          expect(object.process_template).to eq object.baz_qux
        end
      end

      specify "テンプレートはクラス内で共有される" do
        aggregate_failures do
          path_0  = 'foo/bar.erb'
          path_1  = 'baz/qux.erb'
          set_template_contents(path_0 => '<%= foo_bar %>', path_1 => '<%= baz_qux %>')

          objects = [test_class.new(0), test_class.new(1)]

          expect(objects[0].process_template(path_0)).to eq objects[0].foo_bar
          expect(objects[1].process_template(path_1)).to eq objects[1].baz_qux
          expect(objects[0].process_template(path_1)).to eq objects[0].baz_qux
          expect(objects[1].process_template(path_0)).to eq objects[1].foo_bar
        end
      end
    end
  end
end
