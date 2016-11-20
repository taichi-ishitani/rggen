require_relative '../../../spec_helper'

module RgGen::VerilogUtility
  describe PackageDefinition do
    def package_definition(name, &body)
      PackageDefinition.new(name, &body).to_code.to_s
    end

    it "パッケージ定義を行うコードを生成する" do
      expect(
        package_definition(:foo_pkg) { |pkg|
          pkg.body { 'int foo;'}
        }
      ).to eq <<'CODE'
package foo_pkg;
  int foo;
endpackage
CODE
      expect(
        package_definition(:foo_pkg) { |pkg|
          pkg.import_package :foo_pkg
          pkg.import_package :foo_pkg, []
          pkg.import_package :foo_pkg, [:bar]
          pkg.import_package :foo_pkg, [:bar, :baz]
          pkg.body {'int foo;'}
        }
      ).to eq <<'CODE'
package foo_pkg;
  import foo_pkg::*;
  import foo_pkg::*;
  import foo_pkg::bar;
  import foo_pkg::bar, foo_pkg::baz;
  int foo;
endpackage
CODE

      expect(
        package_definition(:foo_pkg) { |pkg|
          pkg.include_file 'foo.svh'
          pkg.include_file 'bar.svh'
          pkg.body { 'int foo;' }
        }
      ).to eq <<'CODE'
package foo_pkg;
  `include "foo.svh"
  `include "bar.svh"
  int foo;
endpackage
CODE

      expect(
        package_definition(:foo_pkg) { |pkg|
          pkg.include_file 'foo.svh'
          pkg.import_package :foo_pkg
          pkg.import_package :bar_pkg
          pkg.include_file 'bar.svh'
          pkg.body { 'int foo;' }
        }
      ).to eq <<'CODE'
package foo_pkg;
  import foo_pkg::*;
  import bar_pkg::*;
  `include "foo.svh"
  `include "bar.svh"
  int foo;
endpackage
CODE
    end
  end
end
