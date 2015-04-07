require_relative  '../spec_helper'

module RGen::RegisterMap::Base
  describe ItemFactory do
    class FooItem < RGen::RegisterMap::Base::Item
      field :foo
      build {|cell| @foo = cell}
    end

    let(:factory) do
      f = ItemFactory.new
      f.register(FooItem)
      f
    end

    let(:configuration) do
      RGen::Configuration::Configuration.new
    end

    let(:component) do
      RGen::InputBase::Component.new
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
    end
  end
end
