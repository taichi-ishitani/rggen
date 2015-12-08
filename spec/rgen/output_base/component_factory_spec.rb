require_relative '../../spec_helper'

module RGen::OutputBase
  describe ComponentFactory do
    let(:configuration) do
      get_component_class(:configuration, 0).new(nil)
    end

    let(:register_map) do
      m = get_component_class(:register_map, 0).new(nil)
      2.times do
        b = get_component_class(:register_map, 1).new(m)
        m.add_child(b)
      end
      m
    end

    let(:item_factories) do
      [:foo, :bar].each_with_object({}) do |n, h|
        f             = ItemFactory.new
        f.target_item = Item
        h[n]          = f
      end
    end

    let(:factory) do
      f                   = ComponentFactory.new
      f.target_component  = Component
      f.item_factories    = item_factories
      f.child_factory     = child_factory
      f.root_factory
      f
    end

    let(:child_factory) do
      f                   = ComponentFactory.new
      f.target_component  = Component
      f
    end

    describe "#create" do
      it "与えられたコンフィグレーション、レジスタマップオブジェクトを用いて、属するアイテムオブジェクトを生成する" do
        item_factories.each_value do |f|
          allow(f).to receive(:create).and_call_original
        end

        component = factory.create(configuration, register_map)

        item_factories.each_value do |f|
          expect(f).to have_received(:create).with(component, configuration, register_map)
        end
      end

      it "与えられたコンフィグレーションオブジェクト、ソースオブジェクトの子オブジェクトを用いて、属する子ジェネレータを生成する" do
        allow(child_factory).to receive(:create).twice.and_call_original

        component = factory.create(configuration, register_map)

        expect(child_factory).to have_received(:create).with(component, configuration, register_map.register_blocks[0])
        expect(child_factory).to have_received(:create).with(component, configuration, register_map.register_blocks[1])
      end

      context "ルートファクトリのとき" do
        before do
          c = Component.new(nil, configuration, register_map)
          expect(c).to receive(:build).with(no_args)
          allow(factory). to receive(:create_component).and_return(c)
        end

        it "生成したコンポーネントの#buildを呼び出す" do
          factory.create(configuration, register_map)
        end
      end

      context "ルートファクトリではないとき" do
        before do
          c = Component.new(nil, configuration, register_map)
          expect(c).not_to receive(:build)
          allow(child_factory). to receive(:create_component).and_return(c)
        end

        it "生成したコンポーネントの#buildを呼び出さない" do
          parent  = Component.new(nil, configuration, register_map)
          child_factory.create(parent, configuration, register_map)
        end
      end
    end
  end
end
