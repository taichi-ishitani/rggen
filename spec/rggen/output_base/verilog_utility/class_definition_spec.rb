require_relative '../../../spec_helper'

module RgGen::OutputBase::VerilogUtility
  describe ClassDefinition do
    before(:all) do
      @verilog  = Class.new {
        include RgGen::OutputBase::VerilogUtility
      }.new
    end

    def class_definition(name, &body)
      ClassDefinition.new(name, &body).to_code.to_s
    end

    def parameter(attributes)
      @verilog.send(:create_declaration, :parameter, attributes)
    end

    def variable(attributes)
      @verilog.send(:create_declaration, :variable, attributes)
    end

    it "クラス定義を行うコードを生成する" do
      expect(
        class_definition(:foo) { |c|
          c.body { 'int foo;' }
        }
      ).to eq <<'CODE'
class foo;
  int foo;
endclass
CODE

      expect(
        class_definition(:foo) { |c|
          c.base :bar
          c.body { 'int foo;' }
        }
      ).to eq <<'CODE'
class foo extends bar;
  int foo;
endclass
CODE

      expect(
        class_definition(:foo) { |c|
          c.parameters  [
            parameter(parameter_type: :parameter , data_type: :type, name: 'P_FOO', default: :uvm_object),
            parameter(parameter_type: :localparam, name: 'L_FOO', default: 1)
          ]
          c.variables   []
          c.body { 'int foo;' }
        }
      ).to eq <<'CODE'
class foo#(
  parameter type P_FOO = uvm_object,
  localparam L_FOO = 1
);
  int foo;
endclass
CODE

      expect(
        class_definition(:foo) { |c|
          c.parameters  []
          c.variables   [
            variable(data_type: :uvm_object, name: 'foo'),
            variable(data_type: :BAR, name: 'bar')
          ]
          c.body { 'int foo;' }
        }
      ).to eq <<'CODE'
class foo;
  uvm_object foo;
  BAR bar;
  int foo;
endclass
CODE

      expect(
        class_definition(:foo) { |c|
          c.parameters  [
            parameter(parameter_type: :parameter , name: 'P_FOO', default: 0)
          ]
          c.variables   [
            variable(data_type: :uvm_object, name: 'foo')
          ]
          c.body { 'int foo;' }
        }
      ).to eq <<'CODE'
class foo#(
  parameter P_FOO = 0
);
  uvm_object foo;
  int foo;
endclass
CODE

    end
  end
end
