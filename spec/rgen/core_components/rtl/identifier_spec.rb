require_relative '../../../spec_helper'

module RGen::Rtl
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

    describe "#to_s" do
      context "#[]でパート選択やビット選択がされていない場合" do
        it "変数名を返す" do
          expect(identifier.to_s).to eq name
        end
      end

      context "#[]にnilが与えられた場合" do
        it "変数名を返す" do
          expect(identifier[nil].to_s).to eq name
        end
      end

      context "#[]でビット選択がされた場合" do
        it "ビット選択込みの変数名を返す" do
          expect(identifier[index].to_s).to eq "#{name}[#{index}]"
        end
      end

      context "#[]で配列が与えられた場合" do
        it "連続したビット選択込みの変数名を返す" do
          expect(identifier[indexes].to_s).to eq "#{name}#{indexes.map { |i| "[#{i}]" }.join}"
        end
      end

      context "#[]でパート選択がされた場合" do
        it "パート選択込みの変数名を返す" do
          expect(identifier[msb, lsb].to_s).to eq "#{name}[#{msb}:#{lsb}]"
        end
      end

      context "複数回、パート選択やビット選択がされた場合" do
        it "全ての選択操作を含む変数名を返す" do
          expect(identifier[indexes][msb, lsb][lsb].to_s).to eq "#{name}#{indexes.map { |i| "[#{i}]" }.join}[#{msb}:#{lsb}][#{lsb}]"
        end
      end
    end
  end
end
