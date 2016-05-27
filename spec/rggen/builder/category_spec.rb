require_relative  '../../spec_helper'

module RgGen::Builder
  describe Category do
    let(:category) do
      Category.new
    end

    let(:item_stores) do
      {
        configuration: ItemStore.new(
          RgGen::InputBase::Item,
          RgGen::InputBase::ItemFactory
        ),
        register_map: ItemStore.new(
          RgGen::InputBase::Item,
          RgGen::InputBase::ItemFactory
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
        expect(item_stores[:configuration]).to receive(:define_simple_item).with(nil, :foo).and_call_original
        expect(item_stores[:configuration]).to receive(:define_simple_item).with(nil, :bar).and_call_original
        expect(item_stores[:register_map ]).to receive(:define_simple_item).with(nil, :foo).and_call_original

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
        it "共有コンテキスト込みで、対象シンプルアイテムの定義を行う" do
          allow(item_stores[:configuration]).to receive(:define_simple_item).and_call_original
          allow(item_stores[:register_map ]).to receive(:define_simple_item).and_call_original

          context = nil
          category.define_simple_item(:foo) do
            shared_context do
            end
            configuration do
            end
            register_map do
            end
            context = @shared_context
          end

          expect(item_stores[:configuration]).to have_received(:define_simple_item).with(context, :foo)
          expect(item_stores[:register_map ]).to have_received(:define_simple_item).with(context, :foo)
        end
      end

      context "複数のアイテム名を与えた場合" do
        it "与えたアイテム名分のシンプルアイテムの定義を行う" do
          expect(item_stores[:configuration]).to receive(:define_simple_item).with(nil, :foo).and_call_original
          expect(item_stores[:configuration]).to receive(:define_simple_item).with(nil, :bar).and_call_original

          category.define_simple_item([:foo, :bar]) do
            configuration {}
          end
        end

        specify "それぞれのシンプルアイテムは、別々の共有コンテキストを持つ" do
          contexts  = []
          category.define_simple_item([:foo, :bar]) do
            shared_context {}
            configuration {}
            contexts  << @shared_context
          end
          expect(contexts[0]).not_to equal(contexts[1])
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
        expect(item_stores[:configuration]).to receive(:define_list_item).with(nil, :foo, nil )
        expect(item_stores[:configuration]).to receive(:define_list_item).with(nil, :bar, nil )
        expect(item_stores[:configuration]).to receive(:define_list_item).with(nil, :foo, :baz)
        expect(item_stores[:register_map ]).to receive(:define_list_item).with(nil, :foo, nil )
        expect(item_stores[:register_map ]).to receive(:define_list_item).with(nil, :foo, :baz)

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

      context "#shared_contextで共有コンテキストを生成した場合" do
        it "共有コンテキスト込みで対象リストアイテムの定義を行う" do
          allow(item_stores[:configuration]).to receive(:define_list_item).and_call_original
          allow(item_stores[:register_map ]).to receive(:define_list_item).and_call_original

          contexts  = []
          category.define_list_item(:foo) do
            shared_context do
            end
            configuration do
            end
            register_map do
            end
            contexts[0] = @shared_context
          end

          category.define_list_item(:bar) do
            configuration do
            end
            register_map do
            end
          end

          category.define_list_item(:bar, :baz) do
            shared_context do
            end
            configuration do
            end
            register_map do
            end
            contexts[1] = @shared_context
          end

          expect(item_stores[:configuration]).to have_received(:define_list_item).with(contexts[0], :foo, nil )
          expect(item_stores[:register_map ]).to have_received(:define_list_item).with(contexts[0], :foo, nil )
          expect(item_stores[:configuration]).to have_received(:define_list_item).with(nil        , :bar, nil )
          expect(item_stores[:register_map ]).to have_received(:define_list_item).with(nil        , :bar, nil )
          expect(item_stores[:configuration]).to have_received(:define_list_item).with(contexts[1], :bar, :baz)
          expect(item_stores[:register_map ]).to have_received(:define_list_item).with(contexts[1], :bar, :baz)
        end
      end

      context "複数のリスト名、または、アイテム名を与えた場合" do
        it "与えたリスト名分、アイテム名分のリストアイテムの定義を行う" do
          expect(item_stores[:configuration]).to receive(:define_list_item).with(nil, :foo, nil ).and_call_original
          expect(item_stores[:configuration]).to receive(:define_list_item).with(nil, :bar, nil ).and_call_original
          expect(item_stores[:configuration]).to receive(:define_list_item).with(nil, :foo, :foo).and_call_original
          expect(item_stores[:configuration]).to receive(:define_list_item).with(nil, :foo, :bar).and_call_original
          category.define_list_item([:foo, :bar]) do
            configuration {}
          end
          category.define_list_item(:foo, [:foo, :bar]) do
            configuration {}
          end
        end

        specify "それぞれのリストアイテムは、別々の共有コンテキストを持つ" do
          contexts  = []
          category.define_list_item([:foo, :bar]) do
            shared_context {}
            configuration {}
            contexts  << @shared_context
          end
          category.define_list_item(:baz) do
            configuration {}
          end
          category.define_list_item(:baz, [:foo, :bar]) do
            shared_context {}
            configuration {}
            contexts  << @shared_context
          end
          expect(contexts[0]).not_to equal(contexts[1])
          expect(contexts[2]).not_to equal(contexts[3])
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
