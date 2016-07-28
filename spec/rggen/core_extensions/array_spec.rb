require_relative  '../../spec_helper'

describe Array do
  describe "#find_by" do
    before(:all) do
      s       = Struct.new(:a, :b, :c)
      @array  = []
      @array  << s.new(0, 1, 2)
      @array  << s.new(0, 1, 3)
    end

    let(:array) do
      @array
    end

    it "引数で指定したアトリビュートを全て持つ最初の要素を返す" do
      expect(array.find_by(a: 0            )).to be array[0]
      expect(array.find_by(      b: 1      )).to be array[0]
      expect(array.find_by(            c: 2)).to be array[0]
      expect(array.find_by(a: 0, b: 1      )).to be array[0]
      expect(array.find_by(a: 0,       c: 3)).to be array[1]
      expect(array.find_by(a: 0, b: 1, c: 2)).to be array[0]
    end

    it "指定したアトリビュートを持つ全て持つ要素がない場合は、nilを返す" do
      expect(array.find_by(a: 0, b: 0, c: 2      )).to be_nil
      expect(array.find_by(                  d: 2)).to be_nil
      expect(array.find_by(a: 0, b: 1,       d: 2)).to be_nil
      expect(array.find_by(a: 0, b: 1, c: 2, d: 3)).to be_nil
    end
  end
end
