require_relative '../../spec_helper'

module RgGen::OutputBase
  describe FileWriter do
    def create_file_writer(pattern, &body)
      FileWriter.new(pattern, body)
    end

    def create_context(&body)
      Object.new.tap do |c|
        def c.create_blank_code; "" end
        c.instance_exec(&body)
      end
    end

    let(:foo_context) do
      create_context do
        def content; "foo" end
        def file_name; "foo_file" end
      end
    end

    let(:bar_context) do
      create_context do
        def content; "bar" end
        def file_name; "bar_file" end
      end
    end

    describe "#write_file" do
      it "コード生成ブロックをコンテキストオブジェクト上で実行した結果をファイルに書き出す" do
        (create_file_writer("test.txt") { content }).tap do |writer|
          expect {
            writer.write_file(foo_context)
          }.to write_binary_file("test.txt", "foo")
          expect {
            writer.write_file(bar_context)
          }.to write_binary_file("test.txt", "bar")
        end

        (create_file_writer("test.txt") { |_| content }).tap do |writer|
          expect {
            writer.write_file(foo_context)
          }.to write_binary_file("test.txt", "foo")
          expect {
            writer.write_file(bar_context)
          }.to write_binary_file("test.txt", "bar")
        end

        (create_file_writer("test.txt") { |_, c| c << content }).tap do |writer|
          expect {
            writer.write_file(foo_context)
          }.to write_binary_file("test.txt", "foo")
          expect {
            writer.write_file(bar_context)
          }.to write_binary_file("test.txt", "bar")
        end
      end

      it "パターンをコンテキスオブジェクトト上で実行した結果をファイル名とする" do
        (create_file_writer('<%= file_name %>.txt') { content }).tap do |writer|
          expect {
            writer.write_file(foo_context)
          }.to write_binary_file("foo_file.txt", "foo")
          expect {
            writer.write_file(bar_context)
          }.to write_binary_file("bar_file.txt", "bar")
        end

        (create_file_writer('baz/<%= file_name %>.txt') { content }).tap do |writer|
          expect {
            writer.write_file(foo_context)
          }.to write_binary_file("baz/foo_file.txt", "foo")
          expect {
            writer.write_file(bar_context)
          }.to write_binary_file("baz/bar_file.txt", "bar")
        end
      end

      it "コンテキストオブジェクトの#create_blank_codeを呼び出して、バッファ用のコードオブジェクトを生成する" do
        allow(File).to receive(:binwrite)
        expect(foo_context).to receive(:create_blank_code).and_call_original
        (create_file_writer("test.txt") { content }).tap do |writer|
          writer.write_file(foo_context)
        end
      end

      context "出力ディレクトリが指定されている場合" do
        it "指定先にファイルを書き出す" do
          (create_file_writer('test.txt') { content }).tap do |writer|
            expect {
              writer.write_file(foo_context, "foo")
            }.to write_binary_file("foo/test.txt", "foo")
            expect {
              writer.write_file(foo_context, "foo/bar")
            }.to write_binary_file("foo/bar/test.txt", "foo")
            expect {
              writer.write_file(foo_context, ["foo", "bar"])
            }.to write_binary_file("foo/bar/test.txt", "foo")
            expect {
              writer.write_file(foo_context, "")
            }.to write_binary_file("test.txt", "foo")
            expect {
              writer.write_file(foo_context, :foo)
            }.to write_binary_file("foo/test.txt", "foo")
            expect {
              writer.write_file(foo_context, 1)
            }.to write_binary_file("1/test.txt", "foo")
          end
        end
      end

      specify "コード生成ブロック内で、パス情報を参照できる" do
        (create_file_writer('<%= file_name %>.txt') { |path| path }).tap do |writer|
          expect {
            writer.write_file(foo_context)
          }.to write_binary_file("foo_file.txt", "foo_file.txt")
          expect {
            writer.write_file(bar_context, "foo")
          }.to write_binary_file("foo/bar_file.txt", "foo/bar_file.txt")
        end
        (create_file_writer('<%= file_name %>.txt') { |path| path.basename }).tap do |writer|
          expect {
            writer.write_file(foo_context)
          }.to write_binary_file("foo_file.txt", "foo_file.txt")
          expect {
            writer.write_file(bar_context, "foo")
          }.to write_binary_file("foo/bar_file.txt", "bar_file.txt")
        end
        (create_file_writer('<%= file_name %>.txt') { |path, code| code << path.dirname }).tap do |writer|
          expect {
            writer.write_file(foo_context)
          }.to write_binary_file("foo_file.txt", ".")
          expect {
            writer.write_file(bar_context, "foo")
          }.to write_binary_file("foo/bar_file.txt", "foo")
        end
      end

      context "出力ディレクトリがない場合" do
        before do
          ["foo", "foo/bar", ".", "."].each do |d|
            expect(FileUtils).to receive(:mkpath).with(match_string(d)).once
          end
        end

        before do
          allow_any_instance_of(Pathname).to receive(:directory?).and_return(false)
        end

        before do
          allow(File).to receive(:binwrite)
        end

        it "出力ディレクトリを作成する" do
          (create_file_writer('test.txt') { content }).tap do |writer|
            writer.write_file(foo_context, "foo"    )
            writer.write_file(foo_context, "foo/bar")
            writer.write_file(foo_context, "./"     )
            writer.write_file(foo_context)
          end
        end
      end
    end
  end
end
