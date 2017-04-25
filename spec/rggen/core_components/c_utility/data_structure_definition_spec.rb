require_relative '../../../spec_helper'

module RgGen::CUtility
  describe DataStructureDefinition do
    def struct_definition(name, &body)
      DataStructureDefinition.new(:struct, name, &body).to_code.to_s
    end

    def union_definition(name, &body)
      DataStructureDefinition.new(:union, name, &body).to_code.to_s
    end

    let(:member_foo) do
      VariableDeclaration.new(data_type: :int, name: 'foo')
    end

    let(:member_bar) do
      VariableDeclaration.new(data_type: :char, name: 'bar', dimensions: [2])
    end

    let(:member_baz) do
      VariableDeclaration.new(data_type: :t_baz, name: 'baz', dimensions: [2, 4])
    end

    let(:members) do
      [member_foo, member_bar, member_baz]
    end

    it "構造体の定義を行うコードを生成する" do
      expect(
        struct_definition(:s_foo) { |s|
          s.members [member_foo]
        }
      ).to eq <<'CODE'
struct s_foo {
  int foo;
};
CODE

      expect(
        struct_definition(:s_foo) { |s|
          s.members members
        }
      ).to eq <<'CODE'
struct s_foo {
  int foo;
  char bar[2];
  t_baz baz[2][4];
};
CODE

      expect(
        struct_definition(:s_foo) { |s|
          s.with_typedef
          s.members members
        }
      ).to eq <<'CODE'
typedef struct {
  int foo;
  char bar[2];
  t_baz baz[2][4];
} s_foo;
CODE

      expect(
        struct_definition(:s_foo) { |s|
          s.with_typedef :t_foo
          s.members members
        }
      ).to eq <<'CODE'
typedef struct s_foo {
  int foo;
  char bar[2];
  t_baz baz[2][4];
} t_foo;
CODE
    end

    it "共用体の定義を行うコードを生成する" do
      expect(
        union_definition(:u_foo) { |u|
          u.members [member_foo]
        }
      ).to eq <<'CODE'
union u_foo {
  int foo;
};
CODE

      expect(
        union_definition(:u_foo) { |u|
          u.members members
        }
      ).to eq <<'CODE'
union u_foo {
  int foo;
  char bar[2];
  t_baz baz[2][4];
};
CODE

      expect(
        union_definition(:u_foo) { |u|
          u.with_typedef
          u.members members
        }
      ).to eq <<'CODE'
typedef union {
  int foo;
  char bar[2];
  t_baz baz[2][4];
} u_foo;
CODE

      expect(
        union_definition(:u_foo) { |u|
          u.with_typedef :t_foo
          u.members members
        }
      ).to eq <<'CODE'
typedef union u_foo {
  int foo;
  char bar[2];
  t_baz baz[2][4];
} t_foo;
CODE
    end
  end
end
