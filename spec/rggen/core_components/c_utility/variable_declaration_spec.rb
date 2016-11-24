require_relative '../../../spec_helper'

module RgGen::CUtility
  describe VariableDeclaration do
    def declaration(attributes)
      VariableDeclaration.new(attributes).to_s
    end

    it "変数宣言を行うコードを生成する" do
      expect(declaration(name: 'foo', data_type: :int                                         )).to eq "int foo"
      expect(declaration(name: 'bar', data_type: :int                                         )).to eq "int bar"
      expect(declaration(name: 'foo', data_type: :char                                        )).to eq "char foo"
      expect(declaration(name: 'foo', data_type: :t_foo                                       )).to eq "t_foo foo"
      expect(declaration(name: 'foo', data_type: :int  , dimensions: [2   ]                   )).to eq "int foo[2]"
      expect(declaration(name: 'foo', data_type: :int  , dimensions: [2, 3]                   )).to eq "int foo[2][3]"
      expect(declaration(name: 'foo', data_type: :int                      , default: 2       )).to eq "int foo = 2"
      expect(declaration(name: 'foo', data_type: :int                      , default: '0x2'   )).to eq "int foo = 0x2"
      expect(declaration(name: 'foo', data_type: :int  , dimensions: [2   ], default: '{0, 1}')).to eq "int foo[2] = {0, 1}"
    end
  end
end
