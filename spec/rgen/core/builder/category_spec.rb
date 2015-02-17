require_relative  '../../../spec_helper'

module RGen::Builder
  describe Category do
    def match_entry(base, factory, *defined_methods)
      have_attributes(
        item_class: have_attributes(
          superclass:       base,
          instance_methods: include(*defined_methods)
        ),
        factory: factory
      )
    end

    let(:category) do
      Category.new
    end

    let(:registries) do
      category.registries
    end

    before do
      category.create_registry(:configuration) do
        base    RGen::Configuration::Item
        factory RGen::Configuration::ItemFactory
      end
      category.create_registry(:register_map) do
        base    RGen::RegisterMap::BitField::Item
        factory RGen::RegisterMap::BitField::ItemFactory
      end
    end

    describe "#create_registry" do
      it "入力された名前でレジストリを生成する" do
        expect(registries[:configuration]).to have_attributes(
          base:    RGen::Configuration::Item,
          factory: RGen::Configuration::ItemFactory
        )
        expect(registries[:register_map]).to have_attributes(
          base:    RGen::RegisterMap::BitField::Item,
          factory: RGen::RegisterMap::BitField::ItemFactory
        )
      end
    end

    describe "#register_entry" do
      before do
        category.register_entry(:foo) do
          configuration do
            define_field :foo
          end
          register_map do
            define_field :foo
          end
        end
        category.register_entry(:bar) do
          configuration do
            define_field :bar
          end
        end
      end

      it "ブロック内で指定した対象のアイテムエントリを生成する" do
        expect(registries[:configuration].entries).to match({
          foo: match_entry(RGen::Configuration::Item, RGen::Configuration::ItemFactory, :foo),
          bar: match_entry(RGen::Configuration::Item, RGen::Configuration::ItemFactory, :bar)
        })
        expect(registries[:register_map].entries).to match({
          foo: match_entry(RGen::RegisterMap::BitField::Item, RGen::RegisterMap::BitField::ItemFactory, :foo)
        })
      end
    end

    describe "#enabled_factories" do
      before do
        [:foo, :bar, :baz].each do |name|
          category.register_entry(name) do
            configuration do
            end
          end
        end
      end

      let(:enabled_factories) do
        category.enable(:foo, :baz)
        category.enabled_factories(:configuration)
      end

      let(:items) do
        owner = RGen::Configuration::Configuration.new
        enabled_factories.each_with_object({}) {|(n, f), h| h[n] = f.create(owner, nil)}
      end

      it "#enableで指定されたアイテムを生成する、引数で指定した対象のファクトリ一覧を返す" do
        expect(items).to match({
          foo: be_kind_of(registries[:configuration].entries[:foo].item_class),
          baz: be_kind_of(registries[:configuration].entries[:baz].item_class)
        })
      end
    end
  end
end
