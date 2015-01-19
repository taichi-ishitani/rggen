require_relative  '../../spec_helper'

module RegisterGenerator::Base
  describe ItemFactory do
    let(:test_factory) do
      ItemFactory.new
    end

    let(:item_a) do
      Class.new(Item)
    end

    let(:item_b) do
      Class.new(Item)
    end

    let(:owner) do
      Component.new
    end

    describe "#create" do
      it "#registerで一番に登録されたItemオブジェクトを生成する" do
        test_factory.register(:item_a, item_a)
        test_factory.register(:item_b, item_b)
        item  = test_factory.create(owner)
        expect(item).to be_kind_of(item_a)
      end
    end
  end
end
