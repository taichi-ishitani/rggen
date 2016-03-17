require_relative '../../../spec_helper'

module RGen::RAL
  describe Item do
    let(:owner) do
      configuration = RGen::InputBase::Component.new(nil)
      register_map  = RGen::InputBase::Component.new(nil)
      RGen::OutputBase::Component.new(nil, configuration, register_map)
    end

    let(:item) do
      Item.new(owner)
    end

    describe "#model_declaration" do
      let(:declarations) do
        [].tap do |d|
          item.instance_eval do
            d << model_declaration(:foo_model , :foo)
            d << model_declaration("bar_model", :bar , dimensions: [2])
            d << model_declaration(:baz_model , "baz", dimensions: [2, 4])
          end
        end
      end

      it "モデルクラス用の変数宣言オブジェクトを生成する" do
        expect(declarations            ).to all(be_instance_of RGen::OutputBase::VerilogUtility::Declaration)
        expect(declarations.map(&:to_s)).to match([
          "rand foo_model foo", "rand bar_model bar[2]", "rand baz_model baz[2][4]"
        ])
      end
    end
  end
end
