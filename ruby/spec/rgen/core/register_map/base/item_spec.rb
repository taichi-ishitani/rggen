require_relative  '../../../../spec_helper'

module RGen::RegisterMap::Base
  describe Item do
    let(:configuration) do
      RGen::Configuration::Configuration.new
    end

    let(:component) do
      RGen::InputBase::Component.new
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
          define_field  :foo
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

    describe "#error" do
      let(:message) do
        "some register map error"
      end

      it "入力されたメッセージと入力セルの位置情報で、RGen::RegisterMapErrorを発生させる" do
        m = message
        i = Class.new(Item) {
          validate do
            error m
          end
        }.new(component)
        i.build(configuration, cell)

        expect{i.validate}.to raise_register_map_error(message, position)
      end
    end
  end
end