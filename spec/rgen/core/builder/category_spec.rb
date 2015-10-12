require_relative  '../../../spec_helper'

module RGen::Builder
  describe Category do
    let(:category) do
      Category.new
    end

    let(:item_stores) do
      {
        configuration: ItemStore.new(
          RGen::InputBase::Item,
          RGen::InputBase::ItemFactory
        ),
        register_map: ItemStore.new(
          RGen::InputBase::Item,
          RGen::InputBase::ItemFactory
        )
      }
    end

    describe "#add_item_store" do
      it "引数で与えられた名前で、アイテム登録用のメソッドと定義する" do
        expect{
          category.add_item_store(:configuration, item_stores[:configuration])
        }.to change {
          category.respond_to?(:configuration)
        }.from(false).to(true)
      end
    end

    describe "#define_simple_item" do
      before do
        item_stores.each do |name, registry|
          category.add_item_store(name, registry)
        end
      end

      it "引数で与えた名前で、ブロック内で指定した対象シンプルアイテムの定義を行う" do
        expect(item_stores[:configuration]).to receive(:define_simple_item).with(:foo)
        expect(item_stores[:configuration]).to receive(:define_simple_item).with(:bar)
        expect(item_stores[:register_map ]).to receive(:define_simple_item).with(:foo)

        category.define_simple_item(:foo) do
          configuration do
            field :foo
          end
          register_map do
            field :foo
          end
        end

        category.define_simple_item(:bar) do
          configuration do
            field :bar
          end
        end
      end

      context "#shared_contextで共有コンテキストオブジェクトを生成した場合" do
        specify "アイテムの定義内でコンテキストオブジェクトを参照できる" do
          contexts  = []
          category.define_simple_item(:foo) do
            shared_context do
            end
            contexts[0] = @shared_context
            configuration do |context|
              contexts[1] = context
            end
            register_map do |context|
              contexts[2] = context
            end
          end

          expect(contexts[1]).to eql contexts[0]
          expect(contexts[2]).to eql contexts[0]
        end
      end
    end

    describe "#define_list_item" do
      before do
        item_stores.each do |name, registry|
          category.add_item_store(name, registry)
        end
      end

      it "引数で与えた名前で、ブロック内で指定した対象リストアイテムの定義を行う" do
        expect(item_stores[:configuration]).to receive(:define_list_item).with(:foo)
        expect(item_stores[:configuration]).to receive(:define_list_item).with(:bar)
        expect(item_stores[:configuration]).to receive(:define_list_item).with(:foo, :baz)
        expect(item_stores[:register_map ]).to receive(:define_list_item).with(:foo)
        expect(item_stores[:register_map ]).to receive(:define_list_item).with(:foo, :baz)

        category.define_list_item(:foo) do
          configuration do
          end
          register_map do
          end
        end

        category.define_list_item(:bar) do
          configuration do
          end
        end

        category.define_list_item(:foo, :baz) do
          configuration do
          end
          register_map do
          end
        end
      end

      context "#shared_contextで共有コンテキストオブジェクトを生成した場合" do
        specify "アイテムの定義内で共有コンテキストオブジェクトを参照できる" do
          contexts  = []

          category.define_list_item(:foo) do
            shared_context do
            end
            contexts[0] = @shared_context
            configuration do |context|
              contexts[1] = context
            end
            register_map do |context|
              contexts[2] = context
            end
          end

          category.define_list_item(:foo, :bar) do
            shared_context do
            end
            contexts[3] = @shared_context
            configuration do |context|
              contexts[4] = context
            end
            register_map do |context|
              contexts[5] = context
            end
          end

          expect(contexts[1]).to eql contexts[0]
          expect(contexts[2]).to eql contexts[0]
          expect(contexts[4]).to eql contexts[3]
          expect(contexts[5]).to eql contexts[3]
        end
      end
    end

    describe "#enable" do
      before do
        item_stores.each do |name, registry|
          category.add_item_store(name, registry)
        end
        [:foo, :bar].each do |item_name|
          category.define_simple_item(item_name) do
            configuration do
            end
            register_map do
            end
          end
        end
        [:baz, :qux].each do |item_name|
          category.define_list_item(item_name) do
            configuration do
            end
            register_map do
            end
          end
        end
      end

      it "与えられたリスト名、アイテム名を引数として、登録されたエントリの#enableを呼び出す" do
        expect(item_stores[:configuration]).to receive(:enable).with([:foo, :baz])
        expect(item_stores[:register_map ]).to receive(:enable).with([:foo, :baz])
        expect(item_stores[:configuration]).to receive(:enable).with(:qux)
        expect(item_stores[:register_map ]).to receive(:enable).with(:qux)
        expect(item_stores[:configuration]).to receive(:enable).with(:qux, :foo)
        expect(item_stores[:register_map ]).to receive(:enable).with(:qux, :foo)
        expect(item_stores[:configuration]).to receive(:enable).with(:qux, [:bar, :baz])
        expect(item_stores[:register_map ]).to receive(:enable).with(:qux, [:bar, :baz])

        category.enable([:foo, :baz])
        category.enable(:qux)
        category.enable(:qux, :foo)
        category.enable(:qux, [:bar, :baz])
      end
    end
  end
end
