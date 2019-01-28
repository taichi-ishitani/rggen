require_relative '../../../spec_helper'

module RgGen::RTL
  describe Item do
    let(:owner) do
      configuration = RgGen::InputBase::Component.new(nil)
      register_map  = RgGen::InputBase::Component.new(nil)
      Component.new(nil, configuration, register_map)
    end

    let(:item) do
      Item.new(owner)
    end

    describe "#wire" do
      before do
        item.instance_eval do
          wire :domain_a, :foo
          wire :domain_a, :bar, width: 2, dimensions: [4]
          wire :domain_b, :baz, name: 'w_baz'
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq 'w_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "wire宣言用のVariableDeclarationオブジェクトを生成し、#signal_declarationsに追加する" do
        expect(item.signal_declarations(:domain_a)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.signal_declarations(:domain_a)[0].to_s).to eq "wire foo"
        expect(item.signal_declarations(:domain_a)[1]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.signal_declarations(:domain_a)[1].to_s).to eq "wire [1:0] bar[4]"
        expect(item.signal_declarations(:domain_b)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.signal_declarations(:domain_b)[0].to_s).to eq "wire w_baz"
      end
    end

    describe "#reg" do
      before do
        item.instance_eval do
          reg :domain_a, :foo
          reg :domain_a,:bar, width: 2, dimensions: [4]
          reg :domain_b,:baz, name: 'r_baz'
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq 'r_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "reg宣言用のVariableDeclarationオブジェクトを生成し、#signal_declarationsに追加する" do
        expect(item.signal_declarations(:domain_a)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.signal_declarations(:domain_a)[0].to_s).to eq "reg foo"
        expect(item.signal_declarations(:domain_a)[1]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.signal_declarations(:domain_a)[1].to_s).to eq "reg [1:0] bar[4]"
        expect(item.signal_declarations(:domain_b)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.signal_declarations(:domain_b)[0].to_s).to eq "reg r_baz"
      end
    end

    describe "#logic" do
      before do
        item.instance_eval do
          logic :domain_a, :foo
          logic :domain_a, :bar, width: 2, dimensions: [4]
          logic :domain_b, :baz, name: 'l_baz'
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq 'l_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "logic宣言用のVariableDeclarationオブジェクトを生成し、#signal_declarationsに追加する" do
        expect(item.signal_declarations(:domain_a)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.signal_declarations(:domain_a)[0].to_s).to eq "logic foo"
        expect(item.signal_declarations(:domain_a)[1]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.signal_declarations(:domain_a)[1].to_s).to eq "logic [1:0] bar[4]"
        expect(item.signal_declarations(:domain_b)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.signal_declarations(:domain_b)[0].to_s).to eq "logic l_baz"
      end
    end

    describe "#interface" do
      before do
        item.instance_eval do
          interface :domain_a, :foo, type: :test_bus_if
          interface :domain_a, :bar, type: :test_bus_if, parameters: [2, 4], dimensions: [2, 4]
          interface :domain_b, :baz, type: :test_bus_if, name: :baz_if
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq 'baz_if'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "interfaceインスタンス用のInterfaceInstanceオブジェクトを生成し、#signal_declarationsに追加する" do
        expect(item.signal_declarations(:domain_a)[0]     ).to be_instance_of RgGen::VerilogUtility::InterfaceInstance
        expect(item.signal_declarations(:domain_a)[0].to_s).to eq "test_bus_if foo()"
        expect(item.signal_declarations(:domain_a)[1]     ).to be_instance_of RgGen::VerilogUtility::InterfaceInstance
        expect(item.signal_declarations(:domain_a)[1].to_s).to eq "test_bus_if #(2, 4) bar[2][4]()"
        expect(item.signal_declarations(:domain_b)[0]     ).to be_instance_of RgGen::VerilogUtility::InterfaceInstance
        expect(item.signal_declarations(:domain_b)[0].to_s).to eq "test_bus_if baz_if()"
      end
    end

    describe "#input" do
      before do
        item.instance_eval do
          input :domain_a, :foo
          input :domain_a, :bar, width: 2, dimensions: [4]
          input :domain_b, :baz, name: 'i_baz'
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq 'i_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "input宣言用のVariableDeclarationオブジェクトを生成し、#port_declarationsに追加する" do
        expect(item.port_declarations(:domain_a)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.port_declarations(:domain_a)[0].to_s).to eq "input foo"
        expect(item.port_declarations(:domain_a)[1]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.port_declarations(:domain_a)[1].to_s).to eq "input [1:0] bar[4]"
        expect(item.port_declarations(:domain_b)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.port_declarations(:domain_b)[0].to_s).to eq "input i_baz"
      end
    end

    describe "#output" do
      before do
        item.instance_eval do
          output :domain_a, :foo
          output :domain_a, :bar, width: 2, dimensions: [4]
          output :domain_b, :baz, name: 'o_baz'
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq 'o_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "output宣言用のVariableDeclarationオブジェクトを生成し、#port_declarationsに追加する" do
        expect(item.port_declarations(:domain_a)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.port_declarations(:domain_a)[0].to_s).to eq "output foo"
        expect(item.port_declarations(:domain_a)[1]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.port_declarations(:domain_a)[1].to_s).to eq "output [1:0] bar[4]"
        expect(item.port_declarations(:domain_b)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.port_declarations(:domain_b)[0].to_s).to eq "output o_baz"
      end
    end

    describe "#interface_port" do
      before do
        item.instance_eval do
          interface_port :domain_a, :foo, type: :test_bus_if
          interface_port :domain_a, :bar, type: :test_bus_if, modport: :slave, dimensions: [2, 4]
          interface_port :domain_b, :baz, type: :test_bus_if, name: :baz_if
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq 'baz_if'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "output宣言用のVariableDeclarationオブジェクトを生成し、#port_declarationsに追加する" do
        expect(item.port_declarations(:domain_a)[0]     ).to be_instance_of RgGen::VerilogUtility::InterfacePort
        expect(item.port_declarations(:domain_a)[0].to_s).to eq "test_bus_if foo"
        expect(item.port_declarations(:domain_a)[1]     ).to be_instance_of RgGen::VerilogUtility::InterfacePort
        expect(item.port_declarations(:domain_a)[1].to_s).to eq "test_bus_if.slave bar[2][4]"
        expect(item.port_declarations(:domain_b)[0]     ).to be_instance_of RgGen::VerilogUtility::InterfacePort
        expect(item.port_declarations(:domain_b)[0].to_s).to eq "test_bus_if baz_if"
      end
    end

    describe "#parameter" do
      before do
        item.instance_eval do
          parameter :domain_a, :foo, default: 0
          parameter :domain_a, :bar, width: 2, dimensions: [4], default: "'{0, 1, 2, 3}"
          parameter :domain_b, :baz, name: 'p_baz', default: 1
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq 'p_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "parameter宣言用のVariableDeclarationオブジェクトを生成し、#parameter_declarationsに追加する" do
        expect(item.parameter_declarations(:domain_a)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.parameter_declarations(:domain_a)[0].to_s).to eq "parameter foo = 0"
        expect(item.parameter_declarations(:domain_a)[1]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.parameter_declarations(:domain_a)[1].to_s).to eq "parameter [1:0] bar[4] = '{0, 1, 2, 3}"
        expect(item.parameter_declarations(:domain_b)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.parameter_declarations(:domain_b)[0].to_s).to eq "parameter p_baz = 1"
      end
    end

    describe "#localparam" do
      before do
        item.instance_eval do
          localparam :domain_a, :foo, default: 0
          localparam :domain_a, :bar, width: 2, dimensions: [4], default: "'{0, 1, 2, 3}"
          localparam :domain_b, :baz, name: 'lp_baz', default: 1
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RgGen::VerilogUtility::Identifier
        expect(item.baz.to_s).to eq 'lp_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "localparam宣言用のVariableDeclarationオブジェクトを生成し、#parameter_declarationsに追加する" do
        expect(item.parameter_declarations(:domain_a)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.parameter_declarations(:domain_a)[0].to_s).to eq "localparam foo = 0"
        expect(item.parameter_declarations(:domain_a)[1]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.parameter_declarations(:domain_a)[1].to_s).to eq "localparam [1:0] bar[4] = '{0, 1, 2, 3}"
        expect(item.parameter_declarations(:domain_b)[0]     ).to be_instance_of RgGen::VerilogUtility::Variable
        expect(item.parameter_declarations(:domain_b)[0].to_s).to eq "localparam lp_baz = 1"
      end
    end
  end
end
