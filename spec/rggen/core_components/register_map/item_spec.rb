require_relative  'spec_helper'

module RgGen::RegisterMap
  describe Item do
    before(:all) do
      @item_class = Class.new(Item) do
        field :foo, default: :foo
        build {|cell| @foo = cell}
      end
    end

    let(:item_class) do
      @item_class
    end

    let(:configuration) do
      get_component_class(:configuration, 0).new(nil)
    end

    let(:component) do
      RgGen::RegisterMap::Component.new(nil, configuration)
    end

    let(:value) do
      :foo
    end

    let(:cell) do
      create_cell(value)
    end

    let(:position) do
      cell.position
    end

    let(:item) do
      item_class.new(component)
    end

    describe "#build" do
      it "入力セルの値(#value)でビルドを行う" do
        item.build(cell)
        expect(item.foo).to eq value
      end
    end

    describe "#position" do
      it "#buildで入力されたセルの位置オブジェクトを返す" do
        item.build(cell)
        expect(item.position).to eql position
      end
    end
  end
end