require_relative '../../../spec_helper'

module RGen::GeneratorBase
  describe Item do
    class TestItem < Item
      generate_code :foo do |buffer|
        buffer << 'foo'
      end
      generate_code :bar do |buffer|
        buffer << 'bar'
      end
      write_file "<%= generator.object_id %>.txt" do |buffer|
        generator.generate_code(:foo, :top_down, buffer)
        buffer << "\n"
        generator.generate_code(:bar, :top_down, buffer)
      end
    end

    let(:generator) do
      Generator.new
    end

    let(:item) do
      item  = TestItem.new(generator)
      generator.add_item(item)
      item
    end

    describe "#generate_code" do
      let(:buffer) do
        []
      end

      context ".generate_codeで登録されたコード生成ブロックの種類が指定された場合" do
        it "指定された種類のコード生成ブロックを実行する" do
          item.generate_code(:foo, buffer)
          expect(buffer).to match ['foo']
        end
      end

      context ".generate_codeで登録されていないコード生成の種類が指定された場合" do
        it "何も起こらない" do
          aggregate_failures do
            expect {
              item.generate_code(:baz, buffer)
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
        "#{generator.object_id}.txt"
      end

      let(:contents) do
        "foo\nbar"
      end

      it ".write_fileで登録されたブロックの実行結果を、指定されたパターンのファイル名で書き出す" do
        expect(File).to receive(:write).with(file_name, contents)
        item.write_file
      end

      context "出力ディレクトリの指定がある場合" do
        it "指定されたディレクトリにファイルを書き出す" do
          expect(File).to receive(:write).with("#{output_directory}/#{file_name}", contents)
          item.write_file(output_directory)
        end
      end

      context ".write_fileで生成ブロックが登録されていない場合" do
        let(:item) do
          Class.new(Item).new(generator)
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
