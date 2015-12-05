require_relative '../../../spec_helper'

module RGen::OutputBase
  describe ItemFactory do
    let(:factory) do
      f = ItemFactory.new
      f.target_item = Item
      f
    end

    let(:component) do
      Component.new(nil)
    end

    let(:configuration) do
      RGen::InputBase::Component.new(nil)
    end

    let(:source) do
      RGen::InputBase::Component.new(nil)
    end

    describe "#create" do
      it "与えられたcomponent, configuration, sourceを引数として#create_itemを呼び出す" do
        expect(factory).to receive(:create_item).with(component, configuration, source).and_call_original
        factory.create(component, configuration, source)
      end

      it "与えられたconfiguration, sourceを引数としてItem#buildを呼び出す" do
        item  = Item.new(component)
        expect(item).to receive(:build).with(configuration, source).and_call_original
        allow(Item).to receive(:new).and_return(item)
        factory.create(component, configuration, source)
      end
    end
  end
end
