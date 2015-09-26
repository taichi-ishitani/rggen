require_relative  '../../../spec_helper'

module RGen::Builder
  describe ItemStore do
    let(:item_base) do
      RGen::InputBase::Item
    end

    let(:item_factory) do
      RGen::InputBase::ItemFactory
    end

    let(:item_store) do
      ItemStore.new(item_base, item_factory)
    end

    let(:value_item_entries) do
      item_store.instance_variable_get(:@value_item_entries)
    end

    let(:list_item_entries) do
      item_store.instance_variable_get(:@list_item_entries)
    end

    let(:enabled_items) do
      item_store.instance_variable_get(:@enabled_items)
    end

    let(:shared_context) do
      Object.new
    end

    describe "#define_value_item" do
      before do
        item_store.define_value_item(:foo) do
          field :foo
        end
      end

      let(:entry) do
        value_item_entries[:foo]
      end

      it "#baseを親クラスとしてアイテムクラスを定義し、アイテム名で登録する" do
        expect(entry.item_class).to have_attributes(
          superclass: item_store.base,
          fields:     match([:foo])
        )
      end

      it "#factoryを対応するファクトリとして登録する" do
        expect(entry.factory).to eql item_store.factory
      end

      context "コンテキストオブジェクトが与えられたとき" do
        specify "与えられたコンテキストオブジェクトはブロック内で参照できる" do
          actual_context  = nil
          item_store.define_value_item(:bar, shared_context) do |context|
            actual_context  = context
          end

          expect(actual_context).to eql shared_context
        end
      end

      context "同名の値型アイテムエントリがすでに登録されている場合" do
        it "新しい値型アイテムエントリに差し替える" do
          new_item_class  = nil
          item_store.define_value_item(:foo) do
            new_item_class  = self
          end

          expect(entry.item_class).to eql new_item_class
        end
      end

      context "同名のリスト型アイテムエントリがすでに登録されている場合" do
        before do
          item_store.define_list_item(:bar) do
          end
        end

        it "既存のリスト型アイテムエントリを削除する" do
          expect {
            item_store.define_value_item(:bar) {}
          }.to change {list_item_entries.key?(:bar)}.from(true).to(false)
        end
      end
    end

    describe "#define_list_item" do
      context "引数がリスト名とブロックのとき" do
        let(:entry) do
          list_item_entries[:foo]
        end

        it "リストアイテムエントリを生成し、与えたリスト名で登録する" do
          item_store.define_list_item(:foo) do
          end
          expect(entry).to be_kind_of RGen::Builder::ListItemEntry
          expect(entry.item_base).to be < item_store.base
          expect(entry.factory  ).to be < item_store.factory
        end

        specify "与えたブロックはリストアイテムエントリ内で実行される" do
          e = nil
          item_store.define_list_item(:foo) do
            e = self
          end

          expect(entry).to be e
        end

        context "コンテキストオブジェクトが与えられたとき" do
          specify "与えられたコンテキストオブジェクトはブロック内で参照できる" do
            actual_context  = nil
            item_store.define_list_item(:foo, shared_context) do |context|
              actual_context  = context
            end

            expect(actual_context).to eql shared_context
          end
        end

        context "同名のリスト型アイテムエントリがすでに登録されている場合" do
          before do
            item_store.define_list_item(:foo) do
            end
          end

          it "新しいリスト型アイテムエントリに差し替える" do
            new_entry = nil
            item_store.define_list_item(:foo) do
              new_entry = self
            end

            expect(entry).to eql new_entry
          end
        end

        context "同名の値型アイテムエントリがすでに登録されている場合" do
          before do
            item_store.define_value_item(:foo) do
            end
          end

          it "既存の値型アイテムエントリを削除する" do
            expect{
              item_store.define_list_item(:foo) {}
            }.to change {value_item_entries.key?(:foo)}.from(true).to(false)
          end
        end
      end

      context "引数がリスト名、アイテム名、ブロックのとき" do
        before do
          item_store.define_list_item(:foo) do
          end
        end

        let(:item_name) do
          :bar
        end

        let(:body) do
          proc {}
        end

        it "エントリオブジェクトの#define_list_itemを呼び出して、アイテムの追加を行う" do
          expect(list_item_entries[:foo]).to receive(:define_list_item).with(item_name).and_call_original
          item_store.define_list_item(:foo, item_name, &body)
        end

        context "コンテキストオブジェクトが与えられたとき" do
          specify "与えられたコンテキストオブジェクトはブロック内で参照できる" do
            actual_context  = nil
            item_store.define_list_item(:foo, item_name, shared_context) do |context|
              actual_context  = context
            end

            expect(actual_context).to eql shared_context
          end
        end

        context "登録されていないリスト名を指定したとき" do
          let(:list_name) do
            :bar
          end

          let(:message) do
            "undefined list item entry: #{list_name}"
          end

          it "RGen::Builderエラーを発生させる" do
            expect {
              item_store.define_list_item(list_name, :foo) {}
            }.to raise_error RGen::BuilderError, message
          end
        end
      end
    end

    describe "#enable" do
      before do
        item_store.define_value_item(:foo) {}
        item_store.define_value_item(:bar) {}
        item_store.define_list_item(:baz) {}
        item_store.define_list_item(:qux) {}
      end

      context "引数がアイテム名またはアイテム名の配列のとき" do
        it "enabled_itemsに与えられたアイテム名を与え順番で追加する" do
          item_store.enable(:bar)
          item_store.enable([:qux, :foo])
          expect(enabled_items).to match [:bar, :qux, :foo]
        end

        it "すでに有効にされたアイテムは無視する" do
          item_store.enable(:bar)
          item_store.enable([:qux, :bar])
          item_store.enable(:qux)
          expect(enabled_items).to match [:bar, :qux]
        end

        it "登録されていないアイテムは無視する" do
          item_store.enable(:bar)
          item_store.enable([:qux, :foobar])
          item_store.enable(:quux)
          expect(enabled_items).to match [:bar, :qux]
        end
      end

      context "引数がリスト名と、アイテム名またはアイテム名の配列のとき" do
        it "リスト名で指定されているリスト型アイテムエントリオブジェクトの#enableを呼び出し、リストアイテムの有効化を行う" do
          expect(list_item_entries[:baz]).to receive(:enable).with(:foo)
          expect(list_item_entries[:baz]).to receive(:enable).with([:bar, :baz])
          item_store.enable(:baz, :foo)
          item_store.enable(:baz, [:bar, :baz])
        end

        context "登録されていないリスト名を与えた場合" do
          it "それを無視し、何も起こらない" do
            expect {item_store.enable(:foo, :foo)}.to_not raise_error
          end
        end
      end

      context "引数が3個以上のとき" do
        it "ArgumentErrorを発生させる" do
          message = "wrong number of arguments (3 for 1..2)"
          expect {item_store.enable(:foo, :bar, :baz)}.to raise_error ArgumentError, message
        end
      end
    end

    describe "#build_factories" do
      before do
        [:foo, :bar].each do |name|
          item_store.define_value_item(name) do
          end
        end
        [:baz, :qux].each do |name|
          item_store.define_list_item(name) do
          end
        end
        item_store.enable([:foo, :baz])
        item_store.enable(:qux)
      end

      it "#enableで有効にされたアイテムエントリの#build_factoryを有効にされて順で呼び出し、アイテムファクトリオブジェクトを生成する" do
        [:foo, :baz, :qux].each do |item_name|
          entry = value_item_entries[item_name] || list_item_entries[item_name]
          expect(entry).to receive(:build_factory).ordered.and_call_original
        end
        item_store.build_factories
      end

      it "アイテム名をキーとする、アイテムファクトリオブジェクトハッシュを返す" do
        factories = {}
        [:foo, :baz, :qux].each do |item_name|
          entry = value_item_entries[item_name] || list_item_entries[item_name]
          allow(entry).to receive(:build_factory).and_wrap_original do |m, *args|
            factories[item_name]  = m.call(*args)
            factories[item_name]
          end
        end

        expect(item_store.build_factories).to match factories
      end
    end
  end
end
