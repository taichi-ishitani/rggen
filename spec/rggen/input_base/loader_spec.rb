require_relative  '../../spec_helper'

module RgGen::InputBase
  describe Loader do
    let(:loader) do
      Class.new(Loader)
    end

    describe ".acceptable?" do
      let(:file_names) do
        %w(test.foo test.bar test.FOO test.BaR)
      end

      context "入力ファイルの拡張子が、登録したタイプに含まれる場合" do
        it "真を返す" do
          loader.supported_types  = [:foo, :bar]
          file_names.each do |file_name|
            expect(loader.acceptable?(file_name)).to be_truthy
          end
        end
      end

      context "入力ファイルの拡張子が、登録したタイプに含まれない場合" do
        it "偽を返す" do
          loader.supported_types  = [:baz, :qux]
          file_names.each do |file_name|
            expect(loader.acceptable?(file_name)).to be_falsy
          end
        end
      end
    end

    describe "#load" do
      context "入力ファイルが存在しない場合" do
        before do
          allow(File).to receive(:exist?).with(file_name).and_return(false)
        end

        let(:file_name) do
          "test.foo"
        end

        it "LoadErrorを発生させる" do
          expect {
            loader.new.load(file_name)
          }.to raise_load_error "cannot load such file -- #{file_name}"
        end
      end
    end
  end
end
