require_relative  '../../spec_helper'

describe Forwardable do
  let(:klass) do
    Class.new do
      extend Forwardable
      def self.foo
        @foo  ||= Object.new
      end
      def self.bar
        @bar  ||= Object.new
      end
    end
  end

  let(:object) do
    klass.new
  end

  describe "#def_class_delegator" do
    context "引数がメソッド名のみのとき" do
      before do
        klass.class_eval do
          def_class_delegator :foo
        end
      end

      it "引数で与えられた自クラスのクラスインスタンスメソッドへの委譲メソッドを同名で定義する" do
        expect(object.foo).to eql klass.foo
      end
    end

    context "引数がメソッド名とエイリアス名のとき" do
      before do
        klass.class_eval do
          def_class_delegator :foo, :bar
        end
      end

      it "引数で与えられた自クラスのクラスインスタンスメソッドへの委譲メソッドをエイリアスで定義する" do
        expect(object.bar).to eql klass.foo
      end
    end
  end

  describe "#def_class_delegators" do
    before do
      klass.class_eval do
        def_class_delegators :foo, :bar
      end
    end

    it "引数で与えられた複数の自クラスのクラスインスタンスメソッドへの委譲メソッドを同名で定義する" do
      expect(object.foo).to eql klass.foo
      expect(object.bar).to eql klass.bar
    end
  end
end
