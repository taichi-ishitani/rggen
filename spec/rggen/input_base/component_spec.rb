require_relative  '../../spec_helper'

module RgGen::InputBase
  describe Component do
    describe "#need_no_children?" do
      let(:component) do
        Component.new(nil)
      end

      it "子コンポーネントが不必要であることを設定する" do
        expect {
          component.need_no_children
        }.to change { component.need_children? }.from(be true).to(be false)
      end
    end

    describe "#add_item" do
      let(:owner) do
        Component.new(nil)
      end

      it "自身をレシーバとして、アイテムオブジェクトのフィールドにアクセスできるようにする" do
        fields  = {a:Object.new, b:Object.new}
        item    = Class.new(Item) {
          fields.each do |name, value|
            field(name, default:value)
          end
        }.new(owner)

        owner.add_item(item)
        fields.keys.each do |name|
          expect(owner.send(name)).to eq item.send(name)
        end
      end
    end

    describe "#fields" do
      let(:owner) do
        Component.new(nil)
      end

      let(:fields) do
        [:foo, :bar, :baz, :qux]
      end

      it "直下のアイテムオブジェクトのフィールド一覧を返す" do
        fields.each_slice(2) do |field_slice|
          item  = Class.new(Item) {
            field field_slice[0]
            field field_slice[1]
          }.new(owner)
          owner.add_item(item)
        end
        expect(owner.fields).to match fields
      end
    end

    describe "#validate" do
      let(:root) do
        Component.new(nil)
      end

      let(:children) do
        [Component.new(root), Component.new(root)]
      end

      let(:item_class) do
        Class.new(Item) do
          field :foo
        end
      end

      it "配下の全アイテムオブジェクトの#validateを呼び出す" do
        [root, children].flatten.each do |c|
          2.times do
            item  = item_class.new(c)
            expect(item).to receive(:validate).with(no_args)
            c.add_item(item)
          end
        end
        children.each do |c|
          root.add_child(c)
        end
        root.validate
      end
    end
  end
end
