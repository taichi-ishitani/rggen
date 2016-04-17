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
      RgGen::InputBase::Component.new(nil)
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
        item.build(configuration, cell)
        expect(item.foo).to eq value
      end

      context "入力セルがnilの場合" do
        it "エラーなく実行できる" do
          expect {
            item.build(configuration, nil)
          }.not_to raise_error
          expect(item.foo).to eq :foo
        end
      end
    end

    describe "#configuration" do
      it "#buildで入力されたコンフィグレーションオブジェクトを返す" do
        item.build(configuration, cell)
        expect(item.configuration).to eql configuration
      end
    end

    describe "#position" do
      it "#buildで入力されたセルの位置オブジェクトを返す" do
        item.build(configuration, cell)
        expect(item.position).to eql position
      end
    end
  end
end