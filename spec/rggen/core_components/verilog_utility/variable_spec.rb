require_relative '../../../spec_helper'

module RgGen::VerilogUtility
  describe Variable do
    let(:width) do
      "WIDTH"
    end

    def variable(attributes)
      Variable.new(:variable, attributes).to_s
    end

    def port(attributes)
      Variable.new(:port, attributes).to_s
    end

    def parameter(attributes)
      Variable.new(:parameter, attributes).to_s
    end

    it "変数宣言を行うコードを生成する" do
      expect(variable(name: "foo", data_type: :logic                                                                     )).to eq "logic foo"
      expect(variable(name: "foo", data_type: :reg                                                                       )).to eq "reg foo"
      expect(variable(name: "foo", data_type: :wire                                                                      )).to eq "wire foo"
      expect(variable(name: "foo", data_type: :bar                                                                       )).to eq "bar foo"
      expect(variable(name: "foo", data_type: :logic, width: nil                                                         )).to eq "logic foo"
      expect(variable(name: "foo", data_type: :logic, width: nil  , vector: true                                         )).to eq "logic [0:0] foo"
      expect(variable(name: "foo", data_type: :logic, width: nil  , vector: false                                        )).to eq "logic foo"
      expect(variable(name: "foo", data_type: :logic, width: 1                                                           )).to eq "logic foo"
      expect(variable(name: "foo", data_type: :logic, width: 1    , vector: true                                         )).to eq "logic [0:0] foo"
      expect(variable(name: "foo", data_type: :logic, width: 1    , vector: false                                        )).to eq "logic foo"
      expect(variable(name: "foo", data_type: :logic, width: 2                                                           )).to eq "logic [1:0] foo"
      expect(variable(name: "foo", data_type: :logic, width: 2    , dimensions: nil                                      )).to eq "logic [1:0] foo"
      expect(variable(name: "foo", data_type: :logic, width: 2    , dimensions: [2   ]                                   )).to eq "logic [1:0] foo[2]"
      expect(variable(name: "foo", data_type: :logic, width: 2    , dimensions: [3, 4]                                   )).to eq "logic [1:0] foo[3][4]"
      expect(variable(name: "foo", data_type: :logic, width: 2    , dimensions: [2   ], array_format: :unpacked          )).to eq "logic [1:0] foo[2]"
      expect(variable(name: "foo", data_type: :logic, width: 2    , dimensions: [3, 4], array_format: :unpacked          )).to eq "logic [1:0] foo[3][4]"
      expect(variable(name: "foo", data_type: :logic, width: 2    , dimensions: [2   ], array_format: :vector            )).to eq "logic [3:0] foo"
      expect(variable(name: "foo", data_type: :logic, width: 2    , dimensions: [3, 4], array_format: :vector            )).to eq "logic [23:0] foo"
      expect(variable(name: "foo", data_type: :logic, width: 2    ,                     default: "2'h3"                  )).to eq "logic [1:0] foo = 2'h3"
      expect(variable(name: "foo", data_type: :logic, width: 2    ,                                         random: false)).to eq "logic [1:0] foo"
      expect(variable(name: "foo", data_type: :logic, width: 2    ,                                         random: true )).to eq "rand logic [1:0] foo"
      expect(variable(name: "foo", data_type: :logic, width: 2    , dimensions: [2],    default: "'{0, 1}", random: true )).to eq "rand logic [1:0] foo[2] = '{0, 1}"
      expect(variable(name: "foo", data_type: :logic, width: width                                                       )).to eq "logic [WIDTH-1:0] foo"
      expect(variable(name: "foo", data_type: :logic, width: width, vector: false                                        )).to eq "logic [WIDTH-1:0] foo"
    end

    it "ポート宣言を行うコードを生成する" do
      expect(port(name: "foo",                                                                                                 )).to eq "foo"
      expect(port(name: "foo", direction: :input                                                                               )).to eq "input foo"
      expect(port(name: "foo", direction: :output                                                                              )).to eq "output foo"
      expect(port(name: "foo", direction: :output,                    width: nil                                               )).to eq "output foo"
      expect(port(name: "foo", direction: :output,                    width: nil  , vector: true                               )).to eq "output [0:0] foo"
      expect(port(name: "foo", direction: :output,                    width: nil  , vector: false                              )).to eq "output foo"
      expect(port(name: "foo", direction: :output,                    width: 1                                                 )).to eq "output foo"
      expect(port(name: "foo", direction: :output,                    width: 1    , vector: true                               )).to eq "output [0:0] foo"
      expect(port(name: "foo", direction: :output,                    width: 1    , vector: false                              )).to eq "output foo"
      expect(port(name: "foo", direction: :output,                    width: 2                                                 )).to eq "output [1:0] foo"
      expect(port(name: "foo", direction: :output, data_type: :logic                                                           )).to eq "output logic foo"
      expect(port(name: "foo", direction: :output, data_type: :logic, width: 2                                                 )).to eq "output logic [1:0] foo"
      expect(port(name: "foo", direction: :output,                                  dimensions: nil                            )).to eq "output foo"
      expect(port(name: "foo", direction: :output,                                  dimensions: [2   ]                         )).to eq "output foo[2]"
      expect(port(name: "foo", direction: :output,                                  dimensions: [3, 4]                         )).to eq "output foo[3][4]"
      expect(port(name: "foo", direction: :output, data_type: :logic, width: 2    , dimensions: [3, 4]                         )).to eq "output logic [1:0] foo[3][4]"
      expect(port(name: "foo", direction: :output,                                  dimensions: [2   ], array_format: :unpacked)).to eq "output foo[2]"
      expect(port(name: "foo", direction: :output,                                  dimensions: [3, 4], array_format: :unpacked)).to eq "output foo[3][4]"
      expect(port(name: "foo", direction: :output, data_type: :logic, width: 2    , dimensions: [3, 4], array_format: :unpacked)).to eq "output logic [1:0] foo[3][4]"
      expect(port(name: "foo", direction: :output,                                  dimensions: [2   ], array_format: :vector  )).to eq "output [1:0] foo"
      expect(port(name: "foo", direction: :output,                                  dimensions: [3, 4], array_format: :vector  )).to eq "output [11:0] foo"
      expect(port(name: "foo", direction: :output, data_type: :logic, width: 2    , dimensions: [3, 4], array_format: :vector  )).to eq "output logic [23:0] foo"
      expect(port(name: "foo", direction: :input , data_type: :bit  , width: 2    , default: 3                                 )).to eq "input bit [1:0] foo = 3"
      expect(port(name: "foo", direction: :output,                    width: width                                             )).to eq "output [WIDTH-1:0] foo"
      expect(port(name: "foo", direction: :output,                    width: width, vector: false                              )).to eq "output [WIDTH-1:0] foo"
    end

    it "パラメータ宣言を行うコードを生成する" do
      expect(parameter(name: "FOO", parameter_type: :parameter ,                                                                               default: 0              )).to eq "parameter FOO = 0"
      expect(parameter(name: "FOO", parameter_type: :localparam,                                                                               default: 0              )).to eq "localparam FOO = 0"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                                                                               default: 1              )).to eq "parameter FOO = 1"
      expect(parameter(name: "FOO", parameter_type: :parameter , data_type: :logic,                                                            default: 0              )).to eq "parameter logic FOO = 0"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                    width: nil   ,                                             default: 0              )).to eq "parameter FOO = 0"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                    width: nil   , vector: true,                               default: 0              )).to eq "parameter [0:0] FOO = 0"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                    width: 1     ,                                             default: 0              )).to eq "parameter [0:0] FOO = 0"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                    width: 2     ,                                             default: 0              )).to eq "parameter [1:0] FOO = 0"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                                  dimensions: nil   ,                          default: 0              )).to eq "parameter FOO = 0"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                                  dimensions: [2   ],                          default: "'{0, 1}"      )).to eq "parameter FOO[2] = '{0, 1}"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                                  dimensions: [2, 1],                          default: "'{'{0}, '{1}}")).to eq "parameter FOO[2][1] = '{'{0}, '{1}}"
      expect(parameter(name: "FOO", parameter_type: :parameter , data_type: :logic, width: 2    , dimensions: [2   ],                          default: "'{0, 1}"      )).to eq "parameter logic [1:0] FOO[2] = '{0, 1}"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                                  dimensions: [2, 1], array_format: :unpacked, default: "'{'{0}, '{1}}")).to eq "parameter FOO[2][1] = '{'{0}, '{1}}"
      expect(parameter(name: "FOO", parameter_type: :parameter , data_type: :logic, width: 2    , dimensions: [2   ], array_format: :unpacked, default: "'{0, 1}"      )).to eq "parameter logic [1:0] FOO[2] = '{0, 1}"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                                  dimensions: [2, 1], array_format: :vector  , default: 0              )).to eq "parameter [1:0] FOO = 0"
      expect(parameter(name: "FOO", parameter_type: :parameter , data_type: :logic, width: 2    , dimensions: [2   ], array_format: :vector  , default: 0              )).to eq "parameter logic [3:0] FOO = 0"
      expect(parameter(name: "FOO"                             , data_type: :logic,                                                            default: 0              )).to eq "logic FOO = 0"
      expect(parameter(name: "FOO", parameter_type: :parameter ,                    width: width,                                              default: 0              )).to eq "parameter [WIDTH-1:0] FOO = 0"
    end
  end
end
