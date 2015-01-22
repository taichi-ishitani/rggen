require_relative  '../../spec_helper'

module RegisterGenerator::Base
  describe ComponentFactory do
    let(:component_class) do
      Class.new(Component)
    end

    let(:parent) do
      Component.new
    end

    def create_factory(&body)
      f = Class.new(ComponentFactory, &body).new
      f.register_component(component_class)
      f
    end

    describe "#create" do
      it "#register_componentで登録されたコンポーネントオブジェクトを生成する" do
        f = create_factory
        c = f.create(parent)
        expect(c).to be_kind_of(component_class)
      end

      context "ルートファクトリのとき" do
        it "ルートコンポーネントを生成する" do
          f = create_factory
          f.root_factory
          c = f.create()
          expect(c.parent).to be_nil
        end
      end

      context "ルートファクトリではないとき" do
        it "親コンポーネントの子コンポーネントを生成する" do
          f = create_factory
          c = f.create(parent)
          expect(c.parent).to be parent
        end
      end

      context "子コンポーネントファクトリが登録されているとき" do
        let(:child_factory) do
          create_factory
        end

        it "子コンポーネントを含むコンポーネントオブジェクトを生成する" do
          f = create_factory do
            def create_children(component, *args)
              create_child(component, *args)
            end
          end
          f.register_child_factory(child_factory)

          c = f.create(parent)
          expect(c.children).to match [kind_of(component_class)]
        end
      end

      context "アイテムファクトリが登録されているとき" do
        let(:item_class) do
          Class.new(Item)
        end

        let(:item_name) do
          :item
        end

        let(:item_factory) do
          f = ItemFactory.new
          f.register(item_name, item_class)
          f
        end

        it "アイテムを含むコンポーネントオブジェクトを生成する" do
          f = create_factory do
            def create_items(component, *args)
              @item_factories.each_value do|f|
                f.create(component, *args)
              end
            end
          end
          f.register_item_factory(item_name, item_factory)

          c = f.create(parent)
          expect(c.items).to match [kind_of(item_class)]
        end
      end
    end
  end
end
