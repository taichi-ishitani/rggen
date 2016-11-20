require_relative '../../../spec_helper'

module RgGen::VerilogUtility
  describe ModuleDefinition do
    before(:all) do
      @verilog  = Class.new {
        include RgGen::VerilogUtility
      }.new
    end

    def module_declaration(name, &body)
      ModuleDefinition.new(name, &body).to_code.to_s
    end

    def port(attributes)
      @verilog.send(:create_declaration, :port, attributes)
    end

    def parameter(attributes)
      @verilog.send(:create_declaration, :parameter, attributes)
    end

    def variable(attributes)
      @verilog.send(:create_declaration, :variable, attributes)
    end

    it "モジュール定義を行うコードを生成する" do
      expect(
        module_declaration(:foo) { |m|
          m.body { 'assign foo = 0;' }
        }
      ).to eq <<'CODE'
module foo ();
  assign foo = 0;
endmodule
CODE

      expect(
        module_declaration(:foo) { |m|
          m.parameters []
          m.ports []
          m.signals []
          m.body { 'assign foo = 0;' }
        }
      ).to eq <<'CODE'
module foo ();
  assign foo = 0;
endmodule
CODE

      expect(
        module_declaration(:foo) { |m|
          m.ports [
            port(direction: :input , name: 'i_foo', width: 1),
            port(direction: :output, name: 'o_foo', width: 2)
          ]
          m.body { 'assign foo = 0;' }
        }
      ).to eq <<'CODE'
module foo (
  input i_foo,
  output [1:0] o_foo
);
  assign foo = 0;
endmodule
CODE

      expect(
        module_declaration(:foo) { |m|
          m.parameters [
            parameter(parameter_type: :parameter , name: 'P_FOO', default: 0),
            parameter(parameter_type: :localparam, name: 'L_FOO', default: 1)
          ]
          m.body { 'assign foo = 0;' }
        }
      ).to eq <<'CODE'
module foo #(
  parameter P_FOO = 0,
  localparam L_FOO = 1
)();
  assign foo = 0;
endmodule
CODE

      expect(
        module_declaration(:foo) { |m|
          m.signals [
            variable(data_type: :logic, name: 'foo'),
            variable(data_type: :logic, name: 'bar', width: 2)
          ]
          m.body { 'assign foo = 0;' }
        }
      ).to eq <<'CODE'
module foo ();
  logic foo;
  logic [1:0] bar;
  assign foo = 0;
endmodule
CODE

      expect(
        module_declaration(:foo) { |m|
          m.parameters [
            parameter(parameter_type: :parameter , name: 'P_FOO', default: 0)
          ]
          m.ports [
            port(direction: :input , name: 'i_foo', width: 1)
          ]
          m.signals [
            variable(data_type: :logic, name: 'foo'),
          ]
          m.body { 'assign foo = 0;' }
        }
      ).to eq <<'CODE'
module foo #(
  parameter P_FOO = 0
)(
  input i_foo
);
  logic foo;
  assign foo = 0;
endmodule
CODE
    end
  end
end
