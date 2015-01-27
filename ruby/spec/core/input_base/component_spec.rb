require_relative  '../../spec_helper'

module RegisterGenerator::InputBase
  describe Component do
    describe "#append_item" do
      let(:owner) do
        Component.new
      end

      it "自身をレシーバとして、アイテムオブジェクトのフィールドにアクセスできるようにする" do
        fields  = {a:Object.new, b:Object.new}
        item    = Class.new(Item) {
          fields.each do |name, value|
              define_field(name, default:value)
          end
        }.new(owner)
        fields.keys.each do |name|
          expect(owner.send(name)).to eq item.send(name)
        end
      end
    end

    describe "#validate" do
      let(:root) do
        Component.new
      end

      let(:children) do
        [Component.new(root), Component.new(root)]
      end

      let(:item_class) do
        Class.new(Item) do
          define_field  :foo
        end
      end

      it "配下の全アイテムオブジェクトの#validateを呼び出す" do
        [root, children].flatten.each do |c|
          2.times do
            item  = item_class.new(c)
            expect(item).to receive(:validate).with(no_args)
          end
        end
        root.validate
      end
    end
  end
end
