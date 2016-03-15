require_relative '../../../spec_helper'

module RGen::RTL
  describe Item do
    let(:owner) do
      configuration = RGen::InputBase::Component.new(nil)
      register_map  = RGen::InputBase::Component.new(nil)
      Component.new(nil, configuration, register_map)
    end

    let(:item) do
      Item.new(owner)
    end

    describe "#wire" do
      before do
        item.instance_eval do
          wire :foo
          wire :bar, width: 2, dimensions: [4]
          wire :baz, name: 'w_baz'
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.baz.to_s).to eq 'w_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "wire宣言用のVariableDeclarationオブジェクトを生成し、#signal_declarationsに追加する" do
        expect(item.signal_declarations[0]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.signal_declarations[0].to_s).to eq "wire foo"
        expect(item.signal_declarations[1]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.signal_declarations[1].to_s).to eq "wire [1:0] bar[4]"
        expect(item.signal_declarations[2]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.signal_declarations[2].to_s).to eq "wire w_baz"
      end
    end

    describe "#reg" do
      before do
        item.instance_eval do
          reg :foo
          reg :bar, width: 2, dimensions: [4]
          reg :baz, name: 'r_baz'
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.baz.to_s).to eq 'r_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "reg宣言用のVariableDeclarationオブジェクトを生成し、#signal_declarationsに追加する" do
        expect(item.signal_declarations[0]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.signal_declarations[0].to_s).to eq "reg foo"
        expect(item.signal_declarations[1]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.signal_declarations[1].to_s).to eq "reg [1:0] bar[4]"
        expect(item.signal_declarations[2]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.signal_declarations[2].to_s).to eq "reg r_baz"
      end
    end

    describe "#logic" do
      before do
        item.instance_eval do
          logic :foo
          logic :bar, width: 2, dimensions: [4]
          logic :baz, name: 'l_baz'
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.baz.to_s).to eq 'l_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "logic宣言用のVariableDeclarationオブジェクトを生成し、#signal_declarationsに追加する" do
        expect(item.signal_declarations[0]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.signal_declarations[0].to_s).to eq "logic foo"
        expect(item.signal_declarations[1]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.signal_declarations[1].to_s).to eq "logic [1:0] bar[4]"
        expect(item.signal_declarations[2]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.signal_declarations[2].to_s).to eq "logic l_baz"
      end
    end

    describe "#input" do
      before do
        item.instance_eval do
          input :foo
          input :bar, width: 2, dimensions: [4]
          input :baz, name: 'i_baz'
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.baz.to_s).to eq 'i_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "input宣言用のVariableDeclarationオブジェクトを生成し、#port_declarationsに追加する" do
        expect(item.port_declarations[0]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.port_declarations[0].to_s).to eq "input foo"
        expect(item.port_declarations[1]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.port_declarations[1].to_s).to eq "input [1:0] bar[4]"
        expect(item.port_declarations[2]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.port_declarations[2].to_s).to eq "input i_baz"
      end
    end

    describe "#output" do
      before do
        item.instance_eval do
          output :foo
          output :bar, width: 2, dimensions: [4]
          output :baz, name: 'o_baz'
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.baz.to_s).to eq 'o_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "output宣言用のVariableDeclarationオブジェクトを生成し、#port_declarationsに追加する" do
        expect(item.port_declarations[0]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.port_declarations[0].to_s).to eq "output foo"
        expect(item.port_declarations[1]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.port_declarations[1].to_s).to eq "output [1:0] bar[4]"
        expect(item.port_declarations[2]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.port_declarations[2].to_s).to eq "output o_baz"
      end
    end

    describe "#parameter" do
      before do
        item.instance_eval do
          parameter :foo, default: 0
          parameter :bar, width: 2, dimensions: [4], default: "'{0, 1, 2, 3}"
          parameter :baz, name: 'p_baz', default: 1
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.baz.to_s).to eq 'p_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "parameter宣言用のVariableDeclarationオブジェクトを生成し、#parameter_declarationsに追加する" do
        expect(item.parameter_declarations[0]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.parameter_declarations[0].to_s).to eq "parameter foo = 0"
        expect(item.parameter_declarations[1]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.parameter_declarations[1].to_s).to eq "parameter [1:0] bar[4] = '{0, 1, 2, 3}"
        expect(item.parameter_declarations[2]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.parameter_declarations[2].to_s).to eq "parameter p_baz = 1"
      end
    end

    describe "#localparam" do
      before do
        item.instance_eval do
          localparam :foo, default: 0
          localparam :bar, width: 2, dimensions: [4], default: "'{0, 1, 2, 3}"
          localparam :baz, name: 'lp_baz', default: 1
        end
      end

      it "Identifierオブジェクトを生成し、与えたハンドル名でアクセッサを定義する" do
        expect(item.foo     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.foo.to_s).to eq 'foo'
        expect(item.bar     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.bar.to_s).to eq 'bar'
        expect(item.baz     ).to be_instance_of RGen::OutputBase::Identifier
        expect(item.baz.to_s).to eq 'lp_baz'
      end

      it "#identifiersに与えたハンドル名を追加する" do
        expect(item.identifiers).to match [:foo, :bar, :baz]
      end

      it "localparam宣言用のVariableDeclarationオブジェクトを生成し、#localparam_declarationsに追加する" do
        expect(item.localparam_declarations[0]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.localparam_declarations[0].to_s).to eq "localparam foo = 0"
        expect(item.localparam_declarations[1]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.localparam_declarations[1].to_s).to eq "localparam [1:0] bar[4] = '{0, 1, 2, 3}"
        expect(item.localparam_declarations[2]     ).to be_instance_of RGen::OutputBase::VariableDeclaration
        expect(item.localparam_declarations[2].to_s).to eq "localparam lp_baz = 1"
      end
    end

    describe "#group" do
      before do
        item.instance_eval do
          group(:foo_bar_baz) do
            wire  :foo
            reg   :bar
            logic :baz
          end
          group(:qux_quux) do
            input  :qux
            output :quux
          end
          group(:FOO_BAR) do
            parameter :FOO
            parameter :BAR
          end
          group(:BAZ_QUX) do
            localparam :BAZ
            localparam :QUX
          end
        end
      end

      it "ブロック内で定義した信号、ポート、パラメータをまとめるグループオブジェクトを生成する" do
        expect(item.foo_bar_baz.foo.to_s).to eq "foo"
        expect(item.foo_bar_baz.bar.to_s).to eq "bar"
        expect(item.foo_bar_baz.baz.to_s).to eq "baz"
        expect(item.qux_quux.qux.to_s   ).to eq "qux"
        expect(item.qux_quux.quux.to_s  ).to eq "quux"
        expect(item.FOO_BAR.FOO.to_s    ).to eq "FOO"
        expect(item.FOO_BAR.BAR.to_s    ).to eq "BAR"
        expect(item.BAZ_QUX.BAZ.to_s    ).to eq "BAZ"
        expect(item.BAZ_QUX.QUX.to_s    ).to eq "QUX"
      end

      it "与えたグループ名を#identifiersに追加する" do
        expect(item.identifiers).to match [:foo_bar_baz, :qux_quux, :FOO_BAR, :BAZ_QUX]
      end

      specify "group内で定義された識別子名は#identifiresに追加されない" do
        expect(item.identifiers).not_to include(:foo, :bar, :baz, :qux, :quux, :FOO, :BAR, :BAZ, :QUX)
      end

      specify "#groupを抜けた後は、それぞれの定義メソッドは通常の動作をする" do
        item.instance_eval do
          wire       :foo
          reg        :bar
          logic      :baz
          input      :qux
          output     :quux
          parameter  :FOO
          parameter  :BAR
          localparam :BAZ
          localparam :QUX
        end
        expect(item.identifiers).to match [:foo_bar_baz, :qux_quux, :FOO_BAR, :BAZ_QUX, :foo, :bar, :baz, :qux, :quux, :FOO, :BAR, :BAZ, :QUX]
      end
    end
  end
end
