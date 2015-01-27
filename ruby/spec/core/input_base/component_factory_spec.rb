require_relative  '../../spec_helper'

module RegisterGenerator::InputBase
  describe ComponentFactory do
    describe "#create" do
      context "ルートファクトリのとき" do
        it "生成したコンポーネントオブジェクトの#validateを呼び出す" do
          component = Component.new
          expect(component).to receive(:validate).with(no_args)

          f = Class.new(ComponentFactory) {
            define_method(:create_component) do |*args|
              component
            end
          }.new
          f.root_factory
          f.create
        end
      end

      context "ルートファクトリではないとき" do
        let(:parent) do
          Component.new
        end

        it "生成したコンポーネントオブジェクトの#validateを呼び出さない" do
          component = Component.new(parent)
          expect(component).not_to receive(:validate)

          f = Class.new(ComponentFactory) {
            define_method(:create_component) do |*args|
              component
            end
          }.new
          f.create(parent)
        end
      end
    end
  end
end
