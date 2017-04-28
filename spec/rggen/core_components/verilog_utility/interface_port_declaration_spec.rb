require_relative '../../../spec_helper'

module RgGen::VerilogUtility
  describe InterfacePortDeclaration do
    def interface_port(attribute)
      InterfacePortDeclaration.new(attribute).to_s
    end

    it "インターフェースポート宣言を行うコードを生成する" do
      expect(interface_port(type: :foo_bus_if,                name: :bus_if                    )).to eq "foo_bus_if bus_if"
      expect(interface_port(type: :foo_bus_if, modport: :bar, name: :bus_if                    )).to eq "foo_bus_if.bar bus_if"
      expect(interface_port(type: :foo_bus_if, modport: nil , name: :bus_if                    )).to eq "foo_bus_if bus_if"
      expect(interface_port(type: :foo_bus_if,                name: :bus_if, dimensions: [2   ])).to eq "foo_bus_if bus_if[2]"
      expect(interface_port(type: :foo_bus_if,                name: :bus_if, dimensions: [2, 4])).to eq "foo_bus_if bus_if[2][4]"
      expect(interface_port(type: :foo_bus_if,                name: :bus_if, dimensions: nil   )).to eq "foo_bus_if bus_if"
      expect(interface_port(type: :foo_bus_if, modport: :bar, name: :bus_if, dimensions: [2, 4])).to eq "foo_bus_if.bar bus_if[2][4]"
    end
  end
end
