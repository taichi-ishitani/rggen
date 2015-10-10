require_relative '../../../spec_helper'

module RGen::GeneratorBase
  describe Item do
    class TestItem < Item
      generate_code :foo do |buffer|
        buffer << 'foo'
      end
      generate_code :bar do |buffer|
        buffer << 'bar'
      end
    end

    let(:owner) do
      Generator.new
    end

    let(:configuration) do
      RGen::InputBase::Component.new
    end

    let(:source) do
      RGen::InputBase::Component.new
    end

    let(:context) do
      Object.new
    end

    let(:item_without_context) do
      TestItem.new(owner, configuration, source)
    end

    let(:item_with_context) do
      TestItem.new(owner, configuration, source, context)
    end

    let(:item) do
      item_without_context
    end

    describe "#configuration" do
      it "与えられたコンフィグレーションオブジェクトを返す" do
        expect(item.configuration).to eql configuration
      end
    end

    describe "#source" do
      it "与えられたソースオブジェクトを返す" do
        expect(item.source).to eql source
      end
    end

    describe "#context" do
      context "コンテキストオブジェクトが与えられた場合" do
        it "与えられたコンテキストオブジェクトを返す" do
          expect(item_with_context.context).to eql context
        end
      end
    end

    describe "#generate_code" do
      let(:buffer) do
        []
      end

      context ".generate_codeで登録されたコード生成ブロックの種類が指定された場合" do
        it "指定された種類のコード生成ブロックを実行する" do
          item.generate_code(:foo, buffer)
          expect(buffer).to match ['foo']
        end
      end

      context ".generate_codeで登録されていないコード生成の種類が指定された場合" do
        it "何も起こらない" do
          aggregate_failures do
            expect {
              item.generate_code(:baz, buffer)
            }.not_to raise_error
            expect(buffer).to be_empty
          end
        end
      end
    end
  end
end
