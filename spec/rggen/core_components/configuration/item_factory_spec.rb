require_relative  '../../../spec_helper'

module RgGen::Configuration
  describe "item_factory" do
    class FooItem < get_item_base(:configuration, 0)
      field :foo, default: :foo
      build {|data| @foo = data}
    end

    let(:configuration) do
      get_component_class(:configuration, 0).new(nil)
    end

    let(:factory) do
      f             = get_item_factory(:configuration, 0).new
      f.target_item = FooItem
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

        context "#convertがオーバーライドされている場合" do
          before do
            def factory.convert(value)
              value.to_s.upcase
            end
          end

          it "#convertの戻り値でアイテムオブジェクトの生成とビルドを行う" do
            i = factory.create(configuration, data)
            expect(i).to be_kind_of(FooItem).and have_attributes(foo: data.to_s.upcase)
          end
        end
      end

      context "入力データがnilのとき" do
        it "アイテムオブジェクトの生成のみ行う" do
          expect(factory).not_to receive(:convert)
          i = factory.create(configuration, nil)
          expect(i).to be_kind_of(FooItem).and have_attributes(foo: :foo)
        end
      end
    end
  end
end
