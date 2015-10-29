require_relative '../../../../spec_helper'

module RGen::Rtl::Verilog
  describe ParameterDeclaration do
    let(:name) do
      "FOO"
    end

    let(:type) do
      :parameter
    end

    let(:default_value) do
      0
    end

    let(:parameter_declaration) do
      ParameterDeclaration.new(name, type, default_value)
    end

    describe "#name" do
      it "パラメータ名を返す" do
        expect(parameter_declaration.name).to eq name
      end
    end

    describe "#type" do
      it "パラメータ型を返す" do
        expect(parameter_declaration.type).to eq type
      end
    end

    describe "#default_value" do
      it "既定値を返す" do
        expect(parameter_declaration.default_value).to eq default_value
      end
    end
  end
end