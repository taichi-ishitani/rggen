require_relative '../../../spec_helper'

module RgGen::VerilogUtility
  describe Identifier do
    let(:name) do
      "foo"
    end

    let(:index) do
      2
    end

    let(:indexes) do
      [3, 4, 5]
    end

    let(:msb) do
      1
    end

    let(:lsb) do
      0
    end

    let(:identifier) do
      Identifier.new(name)
    end

    def match_identifier(expectation)
      be_a_kind_of(Identifier).and match_string(expectation)
    end

    describe "#[]" do
      context "#[]にnilが与えられた場合" do
        it "そのまま変数を返す" do
          expect(identifier[nil]).to match_identifier name
        end
      end

      context "#[]でビット選択がされた場合" do
        it "ビット選択込みの変数を返す" do
          expect(identifier[index]).to match_identifier "#{name}[#{index}]"
        end
      end

      context "#[]で配列が与えられた場合" do
        it "連続したビット選択込みの変数を返す" do
          expect(identifier[indexes]).to match_identifier "#{name}#{indexes.map { |i| "[#{i}]" }.join}"
        end
      end

      context "#[]でパート選択がされた場合" do
        it "パート選択込みの変数を返す" do
          expect(identifier[msb, lsb]).to match_identifier "#{name}[#{msb}:#{lsb}]"
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
