require_relative '../../spec_helper'

module RgGen::OutputBase
  describe TemplateEngine do
    before(:all) do
      @template_engine  = Class.new(TemplateEngine) do
        def file_extension
          :erb
        end
        def parse_template(path)
          BabyErubis::Text.new.from_str(File.read(path), path)
        end
        def render(context, template)
          template.render(context)
        end
      end
      @context  = Class.new do
        def initialize(v)
          @v  = v
        end

        def foo
          "#{@v} foo"
        end

        def bar
          "#{@v} bar"
        end
      end
    end

    after do
      template_engine.instance_eval do
        @templates.clear
      end
    end

    let(:template_engine) do
      @template_engine.instance
    end

    let(:contexts) do
      Hash.new {|h, v| h[v] = @context.new(v)}
    end

    def set_template_contents(contents)
      contents.each do |p, c|
        expect(File).to receive(:read).with(p).once.and_return(c)
      end
    end

    describe "#process_template" do
      it "与えられたコンテキストオブジェクト上で、テンプレートを処理する" do
        path  = 'foo.erb'
        set_template_contents(path => '<%= object_id %><%= foo %>')
        expect(template_engine.process_template(contexts[0], path)).to eq "#{contexts[0].object_id}#{contexts[0].foo}"
        expect(template_engine.process_template(contexts[1], path)).to eq "#{contexts[1].object_id}#{contexts[1].foo}"
      end

      it "テンプレートを一度だけパースする" do
        set_template_contents('foo.erb' => '<%= foo %>', 'bar.erb' => '<%= bar %>')
        template_engine.process_template(contexts[0], 'foo.erb')
        template_engine.process_template(contexts[1], 'bar.erb')
        template_engine.process_template(contexts[0], 'bar.erb')
        template_engine.process_template(contexts[1], 'foo.erb')
      end

      context "テンプレートのパスが指定された場合" do
        let(:template_contents) do
          {
            'foo.erb' => '<%= foo %>',
            'bar.erb' => '<%= bar %>'
          }
        end

        before do
          set_template_contents(template_contents)
        end

        it "パスで指定したテンプレートを処理する" do
          expect(template_engine.process_template(contexts[0], template_contents.keys[0])).to eq contexts[0].foo
          expect(template_engine.process_template(contexts[1], template_contents.keys[1])).to eq contexts[1].bar
        end
      end

      context "テンプレートのパスが指定されなかった場合" do
        let(:path) do
          File.ext(File.expand_path(__FILE__), '.erb')
        end

        before do
          set_template_contents(path => '<%= bar %>')
        end

        it "呼び出し元のファイルパスからテンプレートパスを取り出し(拡張子を#file_extensionに置換)、処理する" do
          expect(template_engine.process_template(contexts[0])).to eq contexts[0].bar
        end
      end

      context "呼び出し情報が指定された場合" do
        let(:call_info) do
          'foo/bar.rb:2:in `baz'
        end

        let(:path) do
          'foo/bar.erb'
        end

        before do
          set_template_contents(path => '<%= foo %><%= bar %>')
        end

        it "呼び出し情報からからテンプレートのパスを取り出し(拡張子を#file_extensionに置換)、処理する" do
          expect(template_engine.process_template(contexts[0], nil, call_info)).to eq contexts[0].foo + contexts[0].bar
        end
      end
    end
  end
end
