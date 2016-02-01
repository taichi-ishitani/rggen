require_relative '../../spec_helper'

module RGen::Verilog
  describe ParameterDeclaration do
    let(:name) do
      "FOO"
    end

    let(:type) do
      :parameter
    end

    let(:attributes) do
      {type: type}
    end

    let(:parameter_declaration) do
      ParameterDeclaration.new(name, attributes)
    end

    describe "#name" do
      it "パラメータ名を返す" do
        expect(parameter_declaration.name).to eq name
      end
    end

    describe "#type" do
      it "属性で指定したパラメータ型を返す" do
        expect(parameter_declaration.type).to eq type
      end
    end

    describe "#default_value" do
      context "既定値の属性指定がない場合" do
        it "0を返す" do
          expect(parameter_declaration.default_value).to eq 0
        end
      end

      context "既定値の属性指定がある場合" do
        let(:default_value) do
          1
        end

        before do
          attributes[:default_value]  = default_value
        end

        it "指定した既定値を返す" do
          expect(parameter_declaration.default_value).to eq default_value
        end
      end
    end
  end
end