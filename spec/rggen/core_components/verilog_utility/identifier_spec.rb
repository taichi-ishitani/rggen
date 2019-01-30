require_relative '../../../spec_helper'

module RgGen::VerilogUtility
  describe Identifier do
    let(:name) { 'foo' }

    let(:width) { 8 }

    let(:array_dimensions) { [2, 3, 4] }

    let(:array_format) { [:unpacked, :vectored].shuffle.first }

    let(:identifier) do
      Identifier.new(name, width, array_dimensions, array_format)
    end

    def match_identifier(expectation)
      be_a_kind_of(Identifier).and match_string(expectation)
    end

    describe "#[]" do
      context "#[]にnilが与えられた場合" do
        it "そのまま識別子を返す" do
          expect(identifier[nil]).to match_identifier name
        end
      end

      context "#[]でビット選択がされた場合" do
        let(:index) { rand(width - 1) }

        it "ビット選択された識別子を返す" do
          expect(identifier[index]).to match_identifier "#{name}[#{index}]"
        end
      end

      context "配列選択用のインデックスが配列で与えられて" do
        let(:array_index) { [:i, :j, :k] }

        context "配列の出力形式がunpackedの場合" do
          let(:array_format) { :unpacked }

          it "配列選択された識別子を返す" do
            array_selection = array_index.map { |i| "[#{i}]" }.join
            expect(identifier[array_index]).to match_identifier "#{name}#{array_selection}"
          end
        end

        context "配列の出力形式がvectoredの場合" do
          let(:array_format) { :vectored }

          it "ベクトル形式で選択された識別子を返す" do
            total_elements  = 1
            vector_index    = []
            array_dimensions.reverse_each.with_index do |d, i|
              if i.zero?
                vector_index.unshift(array_index.reverse[i])
              else
                vector_index.unshift("#{total_elements}*#{array_index.reverse[i]}")
              end
              total_elements  *= d
            end

            expect(identifier[array_index]).to match_identifier "#{name}[#{width}*(#{vector_index.join('+')})+:#{width}]"
          end
        end
      end

      context "#[]でパート選択がされて、" do
        context "MSBとLSBが異なる場合" do
          let(:msb) { rand(1..(width - 1)) }

          let(:lsb) { rand(0..(msb - 1)) }

          it "パート選択された識別子を返す" do
            expect(identifier[msb, lsb]).to match_identifier "#{name}[#{msb}:#{lsb}]"
          end
        end

        context "MSBとLSBが同じ場合" do
          let(:msb) { rand(0..(width - 1)) }

          let(:lsb) { msb }

          it "ビット選択された識別子を返す" do
            expect(identifier[msb, lsb]).to match_identifier "#{name}[#{msb}]"
          end
        end
      end
    end

    describe "階層アクセス" do
      it "階層アクセスされた変数を返す" do
        expect(identifier.bar    ).to match_identifier "foo.bar"
        expect(identifier.baz    ).to match_identifier "foo.baz"
        expect(identifier.bar.baz).to match_identifier "foo.bar.baz"
      end

      it "型変換メソッドには反応しない" do
        [:to_a, :to_ary, :to_hash, :to_int, :to_io, :to_proc, :to_regexp, :to_str].each do |m|
          expect {
            identifier.send(m)
          }.to raise_error NoMethodError
          expect(identifier).not_to be_respond_to(m)
        end
      end
    end
  end
end
