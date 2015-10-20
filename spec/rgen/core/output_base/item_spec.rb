require_relative '../../../spec_helper'

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
        buffer << 'baz'
      end
    end

    class QuxItem < Item
      write_file "<%= owner.object_id %>.txt" do |buffer|
        owner.generate_code(:foo, :top_down, buffer)
        buffer << "\n"
        owner.generate_code(:bar, :top_down, buffer)
      end
    end

    before do
      @foo_item = FooItem.new(component)
      @bar_item = BarItem.new(component)
      @baz_item = BazItem.new(component)
      @qux_item = QuxItem.new(component)
      [@foo_item, @bar_item, @baz_item].each do |item|
        component.add_item(item)
      end
    end

    let(:component) do
      Component.new
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

    describe "#generate_code" do
      let(:buffer) do
        []
      end

      context ".generate_codeで登録されたコード生成ブロックの種類が指定された場合" do
        it "指定された種類のコード生成ブロックを実行する" do
          foo_item.generate_code(:foo, buffer)
          expect(buffer).to match ['foo']
        end
      end

      context ".generate_codeで複数回コード生成が登録された場合" do
        it "指定された種類のコード生成ブロックを実行する" do
          bar_item.generate_code(:barbar, buffer)
          expect(buffer).to match ['barbar']
          bar_item.generate_code(:bar, buffer)
          expect(buffer).to match ['barbar', 'bar']
        end
      end

      context ".generate_codeで登録されていないコード生成の種類が指定された場合" do
        it "何も起こらない" do
          aggregate_failures do
            expect {
              foo_item.generate_code(:bar, buffer)
            }.not_to raise_error
            expect(buffer).to be_empty
          end
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
        expect(File).to receive(:write).with(file_name, contents)
        qux_item.write_file
      end

      context "出力ディレクトリの指定がある場合" do
        it "指定されたディレクトリにファイルを書き出す" do
          expect(File).to receive(:write).with("#{output_directory}/#{file_name}", contents)
          qux_item.write_file(output_directory)
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
