require_relative '../../../spec_helper'

module RGen::OutputBase::VerilogUtility
  describe SubroutineDeclaration do
    before(:all) do
      @verilog  = Class.new {
        include RGen::OutputBase::VerilogUtility
      }.new
    end

    def function(name, &body)
      SubroutineDeclaration.new(:function, name, &body).to_code.to_s
    end

    def argument(name, attributes)
      @verilog.send(:argument, name, attributes)
    end

    def string(expression)
      @verilog.send(:string, expression)
    end

    def array(*expressions)
      @verilog.send(:array, *expressions)
    end

    def super_foo
      'super.foo();'
    end

    it "ファンクション定義を行うコードを生成する" do
      expect(
        function(:foo) { |f|
          f.body do
            super_foo
          end
        }
      ). to eq <<'CODE'
function foo();
  super.foo();
endfunction
CODE

      expect(
        function(:foo) { |f|
          f.return_type :void
          f.body do |code|
            code << super_foo
          end
        }
      ). to eq <<'CODE'
function void foo();
  super.foo();
endfunction
CODE
      expect(
        function(:foo) { |f|
          f.return_type data_type: :bit
          f.body do |code|
            code << super_foo
          end
        }
      ). to eq <<'CODE'
function bit foo();
  super.foo();
endfunction
CODE
      expect(
        function(:foo) { |f|
          f.return_type data_type: :bit, width: 1
          f.body do |code|
            code << super_foo
          end
        }
      ). to eq <<'CODE'
function bit foo();
  super.foo();
endfunction
CODE
      expect(
        function(:foo) { |f|
          f.return_type data_type: :bit, width: 2
          f.body do |code|
            code << super_foo
          end
        }
      ). to eq <<'CODE'
function bit [1:0] foo();
  super.foo();
endfunction
CODE
      expect(
        function(:foo) { |f|
          f.arguments [argument(:bar, direction: :input, data_type: :string)]
          f.body do |code|
            code << super_foo
          end
        }
      ). to eq <<'CODE'
function foo(input string bar);
  super.foo();
endfunction
CODE
      expect(
        function(:foo) { |f|
          f.arguments [argument(:bar, data_type: :string), argument(:baz, data_type: :bit, width: 2)]
          f.body do |code|
            code << super_foo
          end
        }
      ). to eq <<'CODE'
function foo(string bar, bit [1:0] baz);
  super.foo();
endfunction
CODE
      expect(
        function(:foo) { |f|
          f.return_type :void
          f.arguments [
            argument(:bar, data_type: :string,                  default: string(:bar)),
            argument(:baz, data_type: :bit   , dimensions: [2], default: array(0, 1) )
          ]
          f.body do |code|
            code << super_foo
          end
        }
      ). to eq <<'CODE'
function void foo(string bar = "bar", bit baz[2] = '{0, 1});
  super.foo();
endfunction
CODE
    end
  end
end
