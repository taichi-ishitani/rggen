require_relative  '../../../spec_helper'

module RGen::Configuration
  describe ItemFactory do
    class FooItem < RGen::Configuration::Item
      field :foo, default: :foo
      build {|data| @foo = data}
    end

    let(:configuration) do
      Configuration.new
    end

    let(:factory) do
      f = ItemFactory.new
      f.register(:foo, FooItem)
      f
    end

    describe "#create" do
      context "入力データがnilではないとき" do
        let(:data) do
          :bar
        end

        it "アイテムオブジェクトの生成とビルドを行う" do
          i = factory.create(configuration, data)
          expect(i).to be_kind_of(FooItem).and have_attributes(foo: data)
        end
      end

      context "入力データがnilのとき" do
        it "アイテムオブジェクトの生成のみ行う" do
          i = factory.create(configuration, nil)
          # ビルドを行わないのでデフォルト値のままになっている
          expect(i).to be_kind_of(FooItem).and have_attributes(foo: :foo)
        end
      end
    end
  end
end
