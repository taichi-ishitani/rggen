require_relative  '../../spec_helper'

module RGen::Configuration
  describe Factory do
    let(:factory) do
      f = Factory.new
      f.register_component(Configuration)
      f.register_item_factory(:foo, foo_factory)
      f.register_item_factory(:bar, bar_factory)
      f.register_item_factory(:baz, baz_factory)
      f.register_loader(loader)
      f.root_factory
      f
    end

    [:foo, :bar, :baz].each do |item_name|
      let("#{item_name}_item") do
        Class.new(Item) do
          define_field  item_name, default: item_name
          parse do |data|
            instance_variable_set("@#{item_name}", data)
          end
        end
      end

      let("#{item_name}_factory") do
        f = ItemFactory.new
        f.register(item_name, send("#{item_name}_item"))
        f
      end
    end

    let(:loader) do
      Class.new(RGen::InputBase::Loader) do
        support_types :txt
      end
    end

    describe "#create" do
      it "登録されたアイテムオブジェクト全てを持つコンフィグレーションオブジェクトを生成する" do
        c = factory.create
        expect(c.items).to match [kind_of(foo_item), kind_of(bar_item), kind_of(baz_item)]
      end

      context "入力が無いとき" do
        it "アイテムオブジェクトのパースを行わない" do
          c = factory.create
          expect(c.foo).to eq :foo
          expect(c.bar).to eq :bar
          expect(c.baz).to eq :baz
        end
      end

      context "入力が空文字列のとき" do
        it "アイテムオブジェクトのパースを行わない" do
          c = factory.create("")
          expect(c.foo).to eq :foo
          expect(c.bar).to eq :bar
          expect(c.baz).to eq :baz
        end
      end

      context "ロード結果がHashのとき" do
        before do
          loader.class_eval do
            def load_file(file)
              {:foo => :foofoo, "bar" => :barbar}
            end
          end
        end

        it "ロード結果のキーと同じシンボルのキーを持つアイテムオブジェクトのパースを行う" do
          c = factory.create("test.txt")
          expect(c.foo).to eq :foofoo
          expect(c.bar).to eq :barbar
        end

        it "ロード結果のキーと異なるキーを持つアイテムオブジェクトのパースを行わない" do
          c = factory.create("test.txt")
          expect(c.baz).to eq :baz
        end
      end

      context "ロード結果がHashでないとき" do
        let(:load_data) do
          [1, 2, 3]
        end

        before do
          d = load_data
          loader.class_eval do
            define_method(:load_file) do |file|
              d
            end
          end
        end

        it "LoadErrorを発生させる" do
          expect{factory.create("test.txt")}.to raise_error(RGen::LoadError, "Hash type required for configuration: #{load_data.class}}")
        end
      end
    end
  end
end
