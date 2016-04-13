require_relative  'spec_helper'

module RgGen::RegisterMap
  describe ItemFactory do
    class FooItem < RgGen::RegisterMap::Item
      field :foo
      build {|cell| @foo = cell}
    end

    let(:factory) do
      f             = ItemFactory.new
      f.target_item = FooItem
      f
    end

    let(:configuration) do
      get_component_class(:configuration, 0).new(nil)
    end

    let(:component) do
      RgGen::InputBase::Component.new(nil)
    end

    let(:value) do
      :foo
    end

    let(:cell) do
      create_cell(value)
    end

    describe "#create" do
      it "アイテムオブジェクトの生成とビルドを行う" do
        i = factory.create(component, configuration, cell)
        expect(i).to be_kind_of(FooItem).and have_attributes(foo: value)
      end

      it "componentとcellを引数として、#create_itemを呼び出す" do
        expect(factory).to receive(:create_item).with(component, cell).and_call_original
        factory.create(component, configuration, cell)
      end
    end
  end
end
