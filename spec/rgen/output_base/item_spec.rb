require_relative '../../spec_helper'

module RGen::OutputBase
  describe Item do
    class FooItem < Item
      generate_code :foo do |buffer|
        buffer << 'foo'
      end
    end

    class BarItem < Item
      generate_code :bar do |buffer|
        buffer << 'bar'
      end
      generate_code :barbar do |buffer|
        buffer << 'barbar'
      end
    end

    class BazItem < Item
      generate_code :baz do |buffer|
        buffer << @baz
      end
      build do
        @baz  = "#{object_id}_baz"
      end
    end

    class QuxItem < BazItem
      generate_code :qux do |buffer|
        buffer << @qux
      end
      build do
        @qux  = "#{object_id}_qux"
      end
    end

    class QuuxItem < Item
      generate_code_from_template :quux_0
      generate_code_from_template :quux_1, 'quux/template.erb'

      def quux
        :quux
      end
    end

    class FooBarItem < Item
      write_file "<%= owner.object_id %>.txt" do |buffer|
        owner.generate_code(:foo, :top_down, buffer)
        buffer << "\n"
        owner.generate_code(:bar, :top_down, buffer)
      end
    end

    before do
      @foo_item     = FooItem.new(component)
      @bar_item     = BarItem.new(component)
      @baz_item     = BazItem.new(component)
      @qux_item     = QuxItem.new(component)
      @quux_item    = QuuxItem.new(component)
      @foo_bar_item = FooBarItem.new(component)
      [@foo_item, @bar_item, @baz_item, @qux_item, @quux_item, @foo_bar_item].each do |item|
        component.add_item(item)
      end
    end

    let(:configuration) do
      RGen::InputBase::Component.new(nil)
    end

    let(:register_map) do
      RGen::InputBase::Component.new(nil)
    end

    let(:component) do
      Component.new(nil, configuration, register_map)
    end

    let(:foo_item) do
      @foo_item
    end

    let(:bar_item) do
      @bar_item
    end

    let(:baz_item) do
      @baz_item
    end

    let(:qux_item) do
      @qux_item
    end

    let(:quux_item) do
      @quux_item
    end

    let(:foo_bar_item) do
      @foo_bar_item
    end

    let(:buffer) do
      CodeBlock.new
    end

    describe "#build" do
      context ".buildでブロックが与えられた場合" do
        it "登録されたブロックをアイテムのコンテキストで実行する" do
          baz_item.build
          baz_item.generate_code(:baz, buffer)
          expect(buffer.to_s).to eq "#{baz_item.object_id}_baz"
        end

        context "継承されたとき" do
          specify "登録されたブロックが継承先に引き継がれる" do
            qux_item.build
            qux_item.generate_code(:baz, buffer)
            qux_item.generate_code(:qux, buffer)
            expect(buffer.to_s).to eq  "#{qux_item.object_id}_baz#{qux_item.object_id}_qux"
          end
        end
      end
    end

    describe "#generate_code" do
      context ".generate_codeで登録されたコード生成ブロックの種類が指定された場合" do
        it "指定された種類のコード生成ブロックを実行する" do
          foo_item.generate_code(:foo, buffer)
          expect(buffer.to_s).to eq 'foo'
        end
      end

      context ".generate_code_from_tempalateでテンプレートからのコード生成が指定され、" do
        context "テンプレートのパスが指定されていない場合" do
          before do
            expect(File).to receive(:read).with(File.ext(File.expand_path(__FILE__), '.erb')).and_return('<%= quux %>')
          end

          it "[呼び出しもとのファイル名].erbをテンプレートとしてコードを生成する" do
            quux_item.generate_code(:quux_0, buffer)
            expect(buffer.to_s).to eq 'quux'
          end
        end

        context "テンプレートのパスが指定されている場合" do
          before do
            expect(File).to receive(:read).with('quux/template.erb').and_return('<%= quux %>_<%= quux %>')
          end

          it "指定されたテンプレートからコードを生成する" do
            quux_item.generate_code(:quux_1, buffer)
            expect(buffer.to_s).to eq 'quux_quux'
          end
        end
      end

      context ".generate_codeで複数回コード生成が登録された場合" do
        it "指定された種類のコード生成ブロックを実行する" do
          bar_item.generate_code(:barbar, buffer)
          bar_item.generate_code(:bar   , buffer)
          expect(buffer.to_s).to eq 'barbarbar'
        end
      end

      context ".generate_codeで登録されていないコード生成の種類が指定された場合" do
        it "何も起こらない" do
          aggregate_failures do
            expect {
              foo_item.generate_code(:bar, buffer)
            }.not_to raise_error
            expect(buffer.to_s).to be_empty
          end
        end
      end

      context "継承されたとき" do
        specify "登録されたコード生成ブロックが継承先に引き継がれる" do
          qux_item.build
          qux_item.generate_code(:baz, buffer)
          qux_item.generate_code(:qux, buffer)
          expect(buffer.to_s).to eq "#{qux_item.object_id}_baz#{qux_item.object_id}_qux"
        end
      end
    end

    describe "#write_file" do
      let(:output_directory) do
        '/foo/bar'
      end

      let(:file_name) do
        "#{component.object_id}.txt"
      end

      let(:contents) do
        "foo\nbar"
      end

      it ".write_fileで登録されたブロックの実行結果を、指定されたパターンのファイル名で書き出す" do
        expect(File).to receive(:write).with(file_name, contents, nil, binmode: true)
        foo_bar_item.write_file
      end

      context "出力ディレクトリの指定がある場合" do
        it "指定されたディレクトリにファイルを書き出す" do
          expect(File).to receive(:write).with("#{output_directory}/#{file_name}", contents, nil, binmode: true)
          foo_bar_item.write_file(output_directory)
        end
      end

      context ".write_fileで生成ブロックが登録されていない場合" do
        let(:item) do
          Class.new(Item).new(component)
        end

        it "何も起こらない" do
          expect {
            item.write_file
          }.not_to raise_error
        end
      end
    end
  end
end
