require_relative '../../../spec_helper'

module RgGen::RAL
  describe Item do
    let(:configuration) do
      RgGen::InputBase::Component.new(nil)
    end

    let(:register_map) do
      RgGen::InputBase::Component.new(nil)
    end

    let(:parent) do
      RgGen::RAL::Component.new(nil, configuration, register_map)
    end

    let(:owner) do
      RgGen::RAL::Component.new(parent, configuration, register_map)
    end

    let(:item) do
      Item.new(owner)
    end

    describe "#model_declaration" do
      before do
        item.instance_eval do
          model_declaration(:foo_model , :foo)
          model_declaration("bar_model", :bar , dimensions: [2])
          model_declaration(:baz_model , "baz", dimensions: [2, 4])
        end
      end

      it "モデルクラス用の変数宣言オブジェクトを生成し、親コンポーネントの#sub_model_declarationsに追加する" do
        expect(parent.sub_model_declarations            ).to all(be_instance_of RgGen::OutputBase::VerilogUtility::Declaration)
        expect(parent.sub_model_declarations.map(&:to_s)).to match([
          "rand foo_model foo", "rand bar_model bar[2]", "rand baz_model baz[2][4]"
        ])
      end
    end
  end
end
