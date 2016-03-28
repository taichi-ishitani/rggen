require_relative '../../../spec_helper'

module RGen::OutputBase::VerilogUtility
  describe StructureDefinition do
    before(:all) do
      @structure_declaration  = Class.new(StructureDefinition) do
        def header_code
          "function #{@name}();"
        end

        def footer_code
          'endfunction'
        end
      end
    end

    def structure_declaration(name, &block)
      @structure_declaration.new(name, &block).to_code.to_s
    end

    it "構造の定義を行うコードを生成する" do
      expect(
        structure_declaration(:foo)
      ).to eq <<'CODE'
function foo();
endfunction
CODE

      expect(
        structure_declaration(:foo) {}
      ).to eq <<'CODE'
function foo();
endfunction
CODE

      expect(
        structure_declaration(:foo) { |s|
          s.body { 'foo();'}
        }
      ).to eq <<'CODE'
function foo();
  foo();
endfunction
CODE
      expect(
        structure_declaration(:foo) { |s|
          s.body { |code| code << 'foo();' }
        }
      ).to eq <<'CODE'
function foo();
  foo();
endfunction
CODE

    expect(
        structure_declaration(:foo) { |s|
          s.body { |code| code << "foo();\n" }
        }
      ).to eq <<'CODE'
function foo();
  foo();
endfunction
CODE

    expect(
        structure_declaration(:foo) { |s|
          s.body { |code| code << "foo();" }
          s.body { |code| code << "bar();\n" }
        }
      ).to eq <<'CODE'
function foo();
  foo();
  bar();
endfunction
CODE
    end
  end
end
