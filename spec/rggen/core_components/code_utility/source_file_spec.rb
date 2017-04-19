require_relative '../../../spec_helper'

module RgGen::CodeUtility
  describe SourceFile do
    before(:all) do
      @source_file  = Class.new(SourceFile) do
        ifndef_keyword  :'`ifndef'
        endif_keyword   :'`endif'
        define_keyword  :'`define'
        include_keyword :'`include'
      end
    end

    def source_file(path = nil, &body)
      @source_file.new(path, &body).to_code.to_s
    end

    let(:path) do
      Pathname.new("foo/bar.v")
    end

    describe "#header" do
      it "ファイルヘッダーを挿入する" do
        expect(
          source_file(path) { |f|
            f.header { "// #{f.path}" }
          }
        ).to eq <<'CODE'
// foo/bar.v
CODE

        expect(
          source_file(path) { |f|
            f.header  { |c| c << "// #{f.path}" }
          }
        ).to eq <<'CODE'
// foo/bar.v
CODE
      end

      describe "#include_guard" do
        it "インクルードガードを挿入する" do
          expect(
            source_file(path) { |f|
              f.include_guard
            }
          ).to eq <<'CODE'
`ifndef BAR_V
`define BAR_V
`endif
CODE
        end

        context "ブロックが与えられた場合" do
          it "ブロックの戻り値をマクロ名とする" do
            expect(
              source_file(path) { |f|
                f.include_guard { 'INCLUDE_FOO_V' }
              }
            ).to eq <<'CODE'
`ifndef INCLUDE_FOO_V
`define INCLUDE_FOO_V
`endif
CODE
          end
        end

        context "プリフィックス/サフィックスが指定された場合" do
          it "マクロ名の前後にプリフィックス/サフィックスを挿入する" do
            expect(
              source_file(path) { |f|
                f.include_guard('__')
              }
            ).to eq <<'CODE'
`ifndef __BAR_V__
`define __BAR_V__
`endif
CODE

            expect(
              source_file(path) { |f|
                f.include_guard('_', '___')
              }
            ).to eq <<'CODE'
`ifndef _BAR_V___
`define _BAR_V___
`endif
CODE
          end

          specify "ブロック内でプリフィックス/サフィックスを参照できる" do
            expect(
              source_file(path) { |f|
                f.include_guard('__', '_') { |prefix, suffix|
                  "#{prefix}BAR_V#{suffix}"
                }
              }
            ).to eq <<'CODE'
`ifndef __BAR_V_
`define __BAR_V_
`endif
CODE
          end
        end
      end

      describe "#include_file" do
        it "指定したファイルのインクルードを挿入する" do
          expect(
            source_file(path) { |f|
              f.include_file "foo.vh"
            }
          ).to eq <<'CODE'
`include "foo.vh"
CODE

          expect(
            source_file(path) { |f|
              f.include_file "bar.vh"
              f.include_file "baz.vh"
            }
          ).to eq <<'CODE'
`include "bar.vh"
`include "baz.vh"
CODE
        end
      end

      describe "#body" do
        it "本体コードを挿入する" do
          expect(
            source_file(path) { |f|
              f.body { 'reg foo;' }
            }
          ).to eq <<'CODE'
reg foo;
CODE

          expect(
            source_file(path) { |f|
              f.body { |c|
                c << 'reg bar;' << "\n"
                c << 'reg baz;' << "\n"
              }
            }
          ).to eq <<'CODE'
reg bar;
reg baz;
CODE
        end
      end

      it "ヘッダー、インクルードガード、ファイルインクルード、本体の順でコードを挿入する" do
        expect(
          source_file(path) { |f|
            f.body { 'reg foo;' }
            f.include_file 'foo.v'
            f.include_guard
            f.header { '// foo' }
          }
        ).to eq <<'CODE'
// foo
`ifndef BAR_V
`define BAR_V
`include "foo.v"
reg foo;
`endif
CODE
      end
    end
  end
end
