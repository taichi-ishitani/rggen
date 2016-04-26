require_relative  'spec_helper'

module RgGen::RegisterMap
  describe ItemFactory do
    class FooItem < RgGen::RegisterMap::Item
      field :foo, default: :foo
      build {|cell| @foo = cell}
    end

    let(:factory) do
      f             = ItemFactory.new
      f.target_item = FooItem
      f
    end

    let(:configuration) do
      get_component_class(:configuration, 0).new(nil)
    end

    let(:component) do
      RgGen::RegisterMap::Component.new(nil, configuration)
    end

    let(:value) do
      :bar
    end

    let(:cell) do
      create_cell(value)
    end

    let(:position) do
      cell.position
    end

    describe "#create" do
      context "入力セルがnilではない場合" do
        it "アイテムオブジェクトの生成とビルドを行う" do
          i = factory.create(component, configuration, cell)
          expect(i).to be_kind_of(FooItem).and have_attributes(foo: value, position: position)
        end

        context "#convertがオーバーライドされている場合" do
          before do
            def factory.convert(value)
              value.to_s.upcase
            end
          end

          it "#convertの戻り値でアイテムオブジェクトの生成とビルドを行う" do
            i = factory.create(component, configuration, cell)
            expect(i).to be_kind_of(FooItem).and have_attributes(foo: value.to_s.upcase, position: position)
          end
        end
      end

      context "入力セルがnilの場合" do
        it "アイテムオブジェクトの生成のみ行う" do
          i = factory.create(component, configuration, nil)
          expect(i).to be_kind_of(FooItem).and have_attributes(foo: :foo, position: nil)
        end
      end

      context "入力セルがnilまたは空セルの場合" do
        before do
          expect(factory).not_to receive(:convert)
        end

        it "#convertでの値変換を行わない" do
          factory.create(component, configuration, nil )
          cell.value  = ''
          factory.create(component, configuration, cell)
          cell.value  = nil
          factory.create(component, configuration, cell)
        end
      end
    end
  end
end
