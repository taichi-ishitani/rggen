require_relative '../../../spec_helper'

module RGen::OutputBase
  describe ItemFactory do
    let(:factory) do
      f = ItemFactory.new
      f.target_item = Item
      f
    end

    let(:component) do
      Component.new
    end

    let(:configuration) do
      RGen::InputBase::Component.new
    end

    let(:source) do
      RGen::InputBase::Component.new
    end

    let(:item) do
      factory.create(component, configuration, source)
    end

    describe "#create" do
      it "与えられたコンフィグレーション、ソースオブジェクトを持つアイテムオブジェクトを生成する" do
        aggregate_failures do
          expect(item.configuration).to eql configuration
          expect(item.source       ).to eql source
        end
      end

      it "与えられたcomponent, configuration, sourceを引数として#create_itemを呼び出す" do
        expect(factory).to receive(:create_item).with(component, configuration, source).and_call_original
        factory.create(component, configuration, source)
      end
    end
  end
end
