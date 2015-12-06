require_relative '../../../spec_helper'

module RGen::OutputBase
  describe ItemFactory do
    let(:factory) do
      f = ItemFactory.new
      f.target_item = Item
      f
    end

    let(:component) do
      Component.new(nil, configuration, register_map)
    end

    let(:configuration) do
      RGen::InputBase::Component.new(nil)
    end

    let(:register_map) do
      RGen::InputBase::Component.new(nil)
    end

    describe "#create" do
      it "与えられたcomponent, configuration, register_mapを引数として#create_itemを呼び出す" do
        expect(factory).to receive(:create_item).with(component, configuration, register_map).and_call_original
        factory.create(component, configuration, register_map)
      end
    end
  end
end
