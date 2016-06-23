require_relative  '../../spec_helper'

module RgGen::Base
  describe InternalStruct do
    class InternalStructTest
      extend InternalStruct
      define_struct :foo, [:foo_0]
      define_struct :bar, [:bar_0, :bar_1]
      define_struct :baz, [:baz_0, :baz_1] do
        def baz_0_baz_1
          self.baz_0 + self.baz_1
        end
      end
    end

    let(:object) do
      InternalStructTest.new
    end

    let(:structs) do
      Hash.new do |hash, name|
        hash[name]  = object.send(name)
      end
    end

    describe ".define_struct" do
      it "引数で与えた名前と要素を持つ構造体を定義する" do
        expect(structs[:foo]        ).to be < Struct
        expect(structs[:foo].members).to match [:foo_0]
        expect(structs[:bar]        ).to be < Struct
        expect(structs[:bar].members).to match [:bar_0, :bar_1]
        expect(structs[:baz]        ).to be < Struct
        expect(structs[:baz].members).to match [:baz_0, :baz_1]
      end

      context "ブロックを与えた場合" do
        let(:baz_struct) do
          structs[:baz].new(1, 2)
        end

        it "定義した構造体のコンテキストでブロックを実行する" do
          expect(baz_struct.baz_0_baz_1).to eq 3
        end
      end
    end

    context "継承された場合" do
      let(:inherited_object) do
        Class.new(InternalStructTest).new
      end

      specify "継承先でも定義した構造体を使用できる" do
        expect(inherited_object.send(:foo)).to equal(structs[:foo])
        expect(inherited_object.send(:bar)).to equal(structs[:bar])
        expect(inherited_object.send(:baz)).to equal(structs[:baz])
      end
    end
  end
end
