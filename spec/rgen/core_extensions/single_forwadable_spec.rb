require_relative  '../../spec_helper'

describe SingleForwardable do
  let(:target) do
    o = Object.new
    def o.foo
      @foo  ||= Object.new
    end
    def o.bar
      @bar  ||= Object.new
    end
    o
  end

  let(:object) do
    o = Object.new
    o.extend(SingleForwardable)
    o
  end

  describe "#def_object_delegator" do
    context "引数が対象オブジェクトとメソッド名のとき" do
      before do
        object.def_object_delegator(target, :foo)
      end

      it "引数で与えられた対象オブジェクトのインスタンスメソッドへの委譲メソッドを同名で定義する" do
        expect(object.foo).to eql target.foo
      end
    end

    context "引数が対象オブジェクト、メソッド名とエイリアス名のとき" do
      before do
        object.def_object_delegator(target, :foo, :bar)
      end

      it "引数で与えられた対象オブジェクトのインスタンスメソッドへの委譲メソッドをエイリアス名で定義する" do
        expect(object.bar).to eql target.foo
      end
    end
  end

  describe "#def_object_delegators" do
    before do
      object.def_object_delegators(target, :foo, :bar)
    end

    it "引数で与えられた対象オブジェクトの複数のインスタンスメソッドへの委譲メソッドを同名で定義する" do
      expect(object.foo).to eql target.foo
      expect(object.bar).to eql target.bar
    end
  end
end
