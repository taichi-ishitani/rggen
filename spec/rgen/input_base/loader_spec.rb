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
  end
end
