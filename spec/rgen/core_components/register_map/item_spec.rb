require_relative  'spec_helper'

module RGen::RegisterMap
  describe Item do
    let(:configuration) do
      get_component_class(:configuration, 0).new(nil)
    end

    let(:component) do
      RGen::InputBase::Component.new(nil)
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

    describe "#build" do
      it "入力セルの値(#value)でビルドを行う" do
        i = Class.new(Item) {
          field :foo
          build {|cell| @foo = cell}
        }.new(component)

        i.build(configuration, cell)
        expect(i.foo).to eql value
      end
    end

    describe "#configuration" do
      it "#buildで入力されたコンフィグレーションオブジェクトを返す" do
        i = Class.new(Item).new(component)
        i.build(configuration, cell)

        expect(i.configuration).to eql configuration
      end
    end
  end
end