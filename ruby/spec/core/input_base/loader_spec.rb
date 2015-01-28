require_relative  '../../spec_helper'

module RegisterGenerator::InputBase
  describe Loader do
    let(:loader) do
      Class.new(Loader)
    end

    describe ".support_types" do
      context "引数が0個のとき" do
        it "登録されているタイプ一覧を返す" do
          # 初期状態なので、空を返す
          expect(loader.support_types).to be_empty
        end
      end

      context "引数が1個以上の時" do
        it "与えられたタイプをsupport_typesに追加する" do
          loader.support_types(:foo)
          loader.support_types(:bar, :baz)
          expect(loader.support_types).to match [:foo, :bar, :baz]
        end
      end
    end

    describe ".acceptable?" do
      let(:file_name) do
        "test.foo"
      end

      context "入力ファイルの拡張子が、登録したタイプに含まれる場合" do
        it "真を返す" do
          loader.support_types(:foo, :bar)
          expect(loader.acceptable?(file_name)).to be_truthy
        end
      end

      context "入力ファイルの拡張子が、登録したタイプに含まれない場合" do
        it "偽を返す" do
          loader.support_types(:bar, :baz)
          expect(loader.acceptable?(file_name)).to be_falsy
        end
      end
    end
  end
end
