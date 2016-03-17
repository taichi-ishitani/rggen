require_relative '../../../spec_helper'

module RGen::OutputBase::VerilogUtility
  describe ClassDefinition do
    def class_definition(name, &body)
      ClassDefinition.new(name, &body).to_code.to_s
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
    end
  end
end
