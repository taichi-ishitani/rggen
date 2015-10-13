require_relative  '../../../spec_helper'

module RGen::Configuration
  describe Factory do
    let(:factory) do
      f                   = get_component_factory(:configuration, 0).new
      f.target_component  = get_component_class(:configuration, 0)
      f.item_factories    = {foo: foo_factory, bar: bar_factory, baz: baz_factory}
      f.loaders           = [loader]
      f.root_factory
      f
    end

    [:foo, :bar, :baz].each do |item_name|
      let("#{item_name}_item") do
        Class.new(get_item_base(:configuration, 0)) do
          field item_name, default: item_name
          build do |data|
            instance_variable_set("@#{item_name}", data)
          end
        end
      end

      let("#{item_name}_factory") do
        f             = get_item_factory(:configuration, 0).new
        f.target_item = send("#{item_name}_item")
        f
      end
    end

    let(:loader) do
      Class.new(RGen::InputBase::Loader) do
        self.supported_types  = [:txt]
      end
    end

    describe "#create" do
      it "登録されたアイテムオブジェクト全てを持つコンフィグレーションオブジェクトを生成する" do
        c = factory.create
        expect(c.items).to match [kind_of(foo_item), kind_of(bar_item), kind_of(baz_item)]
      end

      context "入力が無いとき" do
        it "アイテムオブジェクトのビルドを行わない" do
          c = factory.create
          expect(c.foo).to eq :foo
          expect(c.bar).to eq :bar
          expect(c.baz).to eq :baz
        end
      end

      context "入力が空文字列のとき" do
        it "アイテムオブジェクトのビルドを行わない" do
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

        it "ロード結果のキーと同じシンボルのキーを持つアイテムオブジェクトのビルドを行う" do
          c = factory.create("test.txt")
          expect(c.foo).to eq :foofoo
          expect(c.bar).to eq :barbar
        end

        it "ロード結果のキーと異なるキーを持つアイテムオブジェクトのビルドを行わない" do
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
          expect{factory.create("test.txt")}.to raise_load_error "Hash type required for configuration: #{load_data.class}"
        end
      end
    end
  end
end
