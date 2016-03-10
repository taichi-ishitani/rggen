require_relative '../../spec_helper'

module RGen::OutputBase
  describe Declaration do
    def variable_declaration(attributes)
      Declaration.new(:variable, attributes).to_s
    end

    def port_declaration(attributes)
      Declaration.new(:port, attributes).to_s
    end

    def parameter_declaration(attributes)
      Declaration.new(:parameter, attributes).to_s
    end

    it "変数宣言を行うコードを生成する" do
      expect(variable_declaration(name: "foo", data_type: :logic                                                              )).to eq "logic foo"
      expect(variable_declaration(name: "foo", data_type: :reg                                                                )).to eq "reg foo"
      expect(variable_declaration(name: "foo", data_type: :wire                                                               )).to eq "wire foo"
      expect(variable_declaration(name: "foo", data_type: :bar                                                                )).to eq "bar foo"
      expect(variable_declaration(name: "foo", data_type: :logic, width: nil                                                  )).to eq "logic foo"
      expect(variable_declaration(name: "foo", data_type: :logic, width: 1                                                    )).to eq "logic foo"
      expect(variable_declaration(name: "foo", data_type: :logic, width: 2                                                    )).to eq "logic [1:0] foo"
      expect(variable_declaration(name: "foo", data_type: :logic, width: 2, dimensions: nil                                   )).to eq "logic [1:0] foo"
      expect(variable_declaration(name: "foo", data_type: :logic, width: 2, dimensions: [2   ]                                )).to eq "logic [1:0] foo[2]"
      expect(variable_declaration(name: "foo", data_type: :logic, width: 2, dimensions: [3, 4]                                )).to eq "logic [1:0] foo[3][4]"
      expect(variable_declaration(name: "foo", data_type: :logic, width: 2,                  default: "2'h3"                  )).to eq "logic [1:0] foo = 2'h3"
      expect(variable_declaration(name: "foo", data_type: :logic, width: 2,                                      random: false)).to eq "logic [1:0] foo"
      expect(variable_declaration(name: "foo", data_type: :logic, width: 2,                                      random: true )).to eq "rand logic [1:0] foo"
      expect(variable_declaration(name: "foo", data_type: :logic, width: 2, dimensions: [2], default: "'{0, 1}", random: true )).to eq "rand logic [1:0] foo[2] = '{0, 1}"
    end

    it "ポート宣言を行うコードを生成する" do
      expect(port_declaration(name: "foo",                                                                                )).to eq "foo"
      expect(port_declaration(name: "foo", direction: :input                                                              )).to eq "input foo"
      expect(port_declaration(name: "foo", direction: :output                                                             )).to eq "output foo"
      expect(port_declaration(name: "foo", direction: :output,                    width: nil                              )).to eq "output foo"
      expect(port_declaration(name: "foo", direction: :output,                    width: 1                                )).to eq "output foo"
      expect(port_declaration(name: "foo", direction: :output,                    width: 2                                )).to eq "output [1:0] foo"
      expect(port_declaration(name: "foo", direction: :output, data_type: :logic                                          )).to eq "output logic foo"
      expect(port_declaration(name: "foo", direction: :output, data_type: :logic, width: 2                                )).to eq "output logic [1:0] foo"
      expect(port_declaration(name: "foo", direction: :output,                              dimensions: nil               )).to eq "output foo"
      expect(port_declaration(name: "foo", direction: :output,                              dimensions: [2   ]            )).to eq "output foo[2]"
      expect(port_declaration(name: "foo", direction: :output,                              dimensions: [3, 4]            )).to eq "output foo[3][4]"
      expect(port_declaration(name: "foo", direction: :output, data_type: :logic, width: 2, dimensions: [3, 4]            )).to eq "output logic [1:0] foo[3][4]"
      expect(port_declaration(name: "foo", direction: :input , data_type: :bit  , width: 2                    , default: 3)).to eq "input bit [1:0] foo = 3"
    end

    it "パラメータ宣言を行うコードを生成する" do
      expect(parameter_declaration(name: "FOO", parameter_type: :parameter ,                                                   default: 0              )).to eq "parameter FOO = 0"
      expect(parameter_declaration(name: "FOO", parameter_type: :localparam,                                                   default: 0              )).to eq "localparam FOO = 0"
      expect(parameter_declaration(name: "FOO", parameter_type: :parameter ,                                                   default: 1              )).to eq "parameter FOO = 1"
      expect(parameter_declaration(name: "FOO", parameter_type: :parameter , data_type: :logic,                                default: 0              )).to eq "parameter logic FOO = 0"
      expect(parameter_declaration(name: "FOO", parameter_type: :parameter ,                   width: nil,                     default: 0              )).to eq "parameter FOO = 0"
      expect(parameter_declaration(name: "FOO", parameter_type: :parameter ,                   width: 1  ,                     default: 0              )).to eq "parameter [0:0] FOO = 0"
      expect(parameter_declaration(name: "FOO", parameter_type: :parameter ,                   width: 2  ,                     default: 0              )).to eq "parameter [1:0] FOO = 0"
      expect(parameter_declaration(name: "FOO", parameter_type: :parameter ,                               dimensions: nil   , default: 0              )).to eq "parameter FOO = 0"
      expect(parameter_declaration(name: "FOO", parameter_type: :parameter ,                               dimensions: [2   ], default: "'{0, 1}"      )).to eq "parameter FOO[2] = '{0, 1}"
      expect(parameter_declaration(name: "FOO", parameter_type: :parameter ,                               dimensions: [2, 1], default: "'{'{0}, '{1}}")).to eq "parameter FOO[2][1] = '{'{0}, '{1}}"
      expect(parameter_declaration(name: "FOO", parameter_type: :parameter , data_type: :logic, width: 2 , dimensions: [2   ], default: "'{0, 1}"      )).to eq "parameter logic [1:0] FOO[2] = '{0, 1}"
    end
  end
end
