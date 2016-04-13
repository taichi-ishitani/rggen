require_relative  '../../spec_helper'

module RgGen::Base
  describe ComponentFactory do
    let(:component_class) do
      Class.new(Component)
    end

    let(:parent) do
      Component.new(nil)
    end

    def create_factory(&body)
      f = Class.new(ComponentFactory, &body).new
      f.target_component  = component_class
      f
    end

    describe "#create" do
      it "#register_componentで登録されたコンポーネントオブジェクトを生成する" do
        factory   = create_factory
        component = factory.create(parent)
        expect(component).to be_kind_of(component_class)
      end

      context "ルートファクトリのとき" do
        it "ルートコンポーネントを生成する" do
          factory = create_factory
          factory.root_factory
          component = factory.create
          expect(component.parent).to be_nil
        end
      end

      context "ルートファクトリではないとき" do
        let(:factory) do
          create_factory
        end

        it "親コンポーネントの子コンポーネントを生成する" do
          component = factory.create(parent)
          expect(component.parent).to be parent
        end

        it "#add_childを呼び出して、親コンポーネントに生成したコンポーネントを登録する" do
          allow(parent).to receive(:add_child).and_call_original
          component = factory.create(parent)
          expect(parent).to have_received(:add_child).with(component)
        end
      end

      context "子コンポーネントファクトリが登録されているとき" do
        it "子コンポーネントを含むコンポーネントオブジェクトを生成する" do
          child_factory = create_factory
          factory       = create_factory do
            def create_children(component, *args)
              create_child(component, *args)
            end
          end
          factory.child_factory = child_factory

          component = factory.create(parent)
          expect(component.children).to match [kind_of(component_class)]
        end
      end

      context "アイテムファクトリが登録されているとき" do
        let(:item_class) do
          Class.new(Item)
        end

        let(:item_name) do
          :item
        end

        it "アイテムを含むコンポーネントオブジェクトを生成する" do
          item_factory              = ItemFactory.new
          item_factory.target_item  = item_class

          factory = create_factory do
            def create_items(component, *args)
              @item_factories.each_value do|f|
                create_item(f, component, *args)
              end
            end
          end
          factory.item_factories  = {item_name => item_factory}

          component = factory.create(parent)
          expect(component.items).to match [kind_of(item_class)]
        end

        it "Component#add_itemを呼び出して、アイテムオブジェクトを登録する" do
          component     = component_class.new(parent)
          item          = item_class.new(component)

          item_factory  = Class.new(ItemFactory) {
            define_method(:create_item) do |owner, *args|
              item
            end
          }.new

          factory = create_factory do
            define_method(:create_component) do |parent, *args|
              component
            end
            def create_items(component, *args)
              @item_factories.each_value do|f|
                create_item(f, component, *args)
              end
            end
          end
          factory.item_factories  = {item_name => item_factory}

          expect(component).to receive(:add_item).with(item)
          factory.create(parent)
        end
      end
    end
  end
end
