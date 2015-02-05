require_relative  '../../../spec_helper'

module RGen::Configuration
  describe ItemFactory do
    let(:configuration) do
      Configuration.new
    end

    let(:item) do
      Item.new(configuration)
    end

    describe "#create" do
      let(:factory) do
        i = item
        f = Class.new(ItemFactory) {
          define_method(:create_item) do |c, d|
            i
          end
        }.new
        f
      end

      context "入力データがnilではないとき" do
        let(:data) do
          Object.new
        end

        it "生成したアイテムオブジェクトの#buildを呼び出す" do
          expect(item).to receive(:build).with(data)
          factory.create(configuration, data)
        end
      end

      context "入力データがnilのとき" do
        it "生成したアイテムオブジェクトの#buildを呼び出さない" do
          expect(item).not_to receive(:build)
          factory.create(configuration, nil)
        end
      end
    end
  end
end
