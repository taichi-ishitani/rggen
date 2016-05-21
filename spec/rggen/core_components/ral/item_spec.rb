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

    describe "#variable" do
      before do
        item.instance_eval do
          variable :domain_a, :foo, data_type: :foo_type
          variable :domain_b, :bar, data_type: :bar_type, dimensions: [2]
          variable :domain_a, :baz, data_type: :baz_type, name: "BAZ", random: true
        end
      end

      it "識別子オブジェクトを生成し、ハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq "foo"
        expect(item.bar     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq "bar"
        expect(item.baz     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq "BAZ"
      end

      it "#identifersにハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "変数宣言オブジェクトを生成し、#variable_declarationsに追加する" do
        expect(item.variable_declarations(:domain_a)[0]     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Declaration
        expect(item.variable_declarations[:domain_a][0].to_s).to eq "foo_type foo"
        expect(item.variable_declarations(:domain_b)[0]     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Declaration
        expect(item.variable_declarations[:domain_b][0].to_s).to eq "bar_type bar[2]"
        expect(item.variable_declarations(:domain_a)[1]     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Declaration
        expect(item.variable_declarations[:domain_a][1].to_s).to eq "rand baz_type BAZ"
      end
    end

    describe "#parameter" do
      before do
        item.instance_eval do
          parameter :domain_a, :foo, data_type: :type, default: :uvm_object
          parameter :domain_b, :bar, data_type: :int , default: 1
          parameter :domain_a, :baz, name: "BAZ"     , default: 0
        end
      end

      it "識別子オブジェクトを生成し、ハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq "foo"
        expect(item.bar     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq "bar"
        expect(item.baz     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq "BAZ"
      end

      it "#identifersにハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "変数宣言オブジェクトを生成し、#variable_declarationsに追加する" do
        expect(item.parameter_declarations(:domain_a)[0]     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Declaration
        expect(item.parameter_declarations[:domain_a][0].to_s).to eq "type foo = uvm_object"
        expect(item.parameter_declarations(:domain_b)[0]     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Declaration
        expect(item.parameter_declarations[:domain_b][0].to_s).to eq "int bar = 1"
        expect(item.parameter_declarations(:domain_a)[1]     ).to be_instance_of RgGen::OutputBase::VerilogUtility::Declaration
        expect(item.parameter_declarations[:domain_a][1].to_s).to eq "BAZ = 0"
      end
    end
  end
end
