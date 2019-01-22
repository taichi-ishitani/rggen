require_relative '../../../spec_helper'

module RgGen::VerilogUtility
  describe InterfaceInstance do
    def interface(attributes)
      InterfaceInstance.new(attributes).to_s
    end

    it "インターフェースのインスタンスを行うコードを生成する" do
      expect(interface(type: :foo_bus_if, name: :bus_if                                        )).to eq "foo_bus_if bus_if()"
      expect(interface(type: :foo_bus_if, parameters: [2   ], name: :bus_if                    )).to eq "foo_bus_if #(2) bus_if()"
      expect(interface(type: :foo_bus_if, parameters: [2, 4], name: :bus_if                    )).to eq "foo_bus_if #(2, 4) bus_if()"
      expect(interface(type: :foo_bus_if, parameters: nil   , name: :bus_if                    )).to eq "foo_bus_if bus_if()"
      expect(interface(type: :foo_bus_if,                     name: :bus_if, dimensions: [2]   )).to eq "foo_bus_if bus_if[2]()"
      expect(interface(type: :foo_bus_if,                     name: :bus_if, dimensions: [2, 4])).to eq "foo_bus_if bus_if[2][4]()"
      expect(interface(type: :foo_bus_if,                     name: :bus_if, dimensions: nil   )).to eq "foo_bus_if bus_if()"
      expect(interface(type: :foo_bus_if, parameters: [2, 4], name: :bus_if, dimensions: [2, 4])).to eq "foo_bus_if #(2, 4) bus_if[2][4]()"
    end
  end
end
