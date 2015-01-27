require_relative  '../../spec_helper'

module RegisterGenerator::InputBase
  describe Component do
    let(:owner) do
      Component.new
    end

    describe "#append_item" do
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
  end
end
