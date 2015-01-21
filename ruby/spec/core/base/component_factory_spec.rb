require_relative  '../../spec_helper'

module RegisterGenerator::Base
  describe ComponentFactory do
    let(:component_class) do
      Class.new(Component)
    end

    let(:parent) do
      Component.new
    end

    def create_factory(&body)
      f = Class.new(ComponentFactory, &body).new
      f.register_component(component_class)
      f
    end

    describe "#create" do
      it "#register_componentで登録されたコンポーネントオブジェクトを生成する" do
        f = create_factory
        c = f.create(parent)
        expect(c).to be_kind_of(component_class)
      end

      context "ルートファクトリのとき" do
        it "ルートコンポーネントを生成する" do
          f = create_factory
          f.root_factory
          c = f.create()
          expect(c.parent).to be_nil
        end
      end

      context "ルートファクトリではないとき" do
        it "親コンポーネントの子コンポーネントを生成する" do
          f = create_factory
          c = f.create(parent)
          expect(c.parent).to be parent
        end
      end
    end
  end
end
