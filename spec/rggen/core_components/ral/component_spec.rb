require_relative '../../../spec_helper'

module RgGen::RAL
  describe Component do
    def create_item(owner, &body)
      Class.new(Item, &body).new(owner).tap { |i| owner.add_item(i) }
    end

    let(:configuration) do
      RgGen::InputBase::Component.new(nil)
    end

    let(:register_map) do
      RgGen::InputBase::Component.new(nil)
    end

    let(:component) do
      Component.new(nil, configuration, register_map)
    end

    let(:children) do
      2.times.map do
        Component.new(component, configuration, register_map).tap do |c|
          component.add_child(c)
        end
      end
    end

    let(:foo_item) do
      create_item(component) do
        build do
          variable  :domain_0, :foo_0, data_type: :foo_type
          variable  :domain_1, :foo_1, data_type: :foo_type
          parameter :domain_0, :FOO_0, default: 0
          parameter :domain_1, :FOO_1, default: 0
        end
      end
    end

    let(:bar_item) do
      create_item(component) do
        build do
          variable  :domain_0, :bar_0, data_type: :bar_type
          variable  :domain_1, :bar_1, data_type: :bar_type
          parameter :domain_0, :BAR_0, default: 0
          parameter :domain_1, :BAR_1, default: 0
        end
      end
    end

    let(:baz_item) do
      create_item(children[0]) do
        build do
          variable  :domain_0, :baz_0, data_type: :baz_type
          variable  :domain_1, :baz_1, data_type: :baz_type
          variable  :domain_0, :baz_2, data_type: :baz_type
          parameter :domain_0, :BAZ_0, default: 0
          parameter :domain_1, :BAZ_1, default: 0
        end
      end
    end

    let(:qux_item) do
      create_item(children[1]) do
        build do
          variable  :domain_0, :qux_0, data_type: :qux_type
          variable  :domain_1, :qux_1, data_type: :qux_type
          parameter :domain_0, :QUX_0, default: 0
          parameter :domain_1, :QUX_1, default: 0
          parameter :domain_1, :QUX_2, default: 0
        end
      end
    end

    describe "#build" do
      before do
        foo_item
        bar_item
        component.build
      end

      it "アイテムオブジェクトが持つ識別子オブジェクトへのアクセッサを定義する" do
        expect(component.foo_0).to eql foo_item.foo_0
        expect(component.foo_1).to eql foo_item.foo_1
        expect(component.FOO_0).to eql foo_item.FOO_0
        expect(component.FOO_1).to eql foo_item.FOO_1
        expect(component.bar_0).to eql bar_item.bar_0
        expect(component.bar_1).to eql bar_item.bar_1
        expect(component.BAR_0).to eql bar_item.BAR_0
        expect(component.BAR_1).to eql bar_item.BAR_1
      end
    end

    describe "#variable_declarations" do
      before do
        foo_item
        bar_item
        baz_item
        qux_item
        component.build
      end

      it "配下のアイテムオブジェクトが持つ変数宣言オブジェクトの一覧を返す" do
        expect(component.variable_declarations(:domain_0)).to match [
          eql(foo_item.variable_declarations[:domain_0][0]),
          eql(bar_item.variable_declarations[:domain_0][0]),
          eql(baz_item.variable_declarations[:domain_0][0]),
          eql(baz_item.variable_declarations[:domain_0][1]),
          eql(qux_item.variable_declarations[:domain_0][0])
        ]
        expect(component.variable_declarations(:domain_1)).to match [
          eql(foo_item.variable_declarations[:domain_1][0]),
          eql(bar_item.variable_declarations[:domain_1][0]),
          eql(baz_item.variable_declarations[:domain_1][0]),
          eql(qux_item.variable_declarations[:domain_1][0])
        ]
      end
    end

    describe "#parameter_declarations" do
      before do
        foo_item
        bar_item
        baz_item
        qux_item
        component.build
      end

      it "配下のアイテムオブジェクトが持つパラメータ宣言オブジェクトの一覧を返す" do
        expect(component.parameter_declarations(:domain_0)).to match [
          eql(foo_item.parameter_declarations[:domain_0][0]),
          eql(bar_item.parameter_declarations[:domain_0][0]),
          eql(baz_item.parameter_declarations[:domain_0][0]),
          eql(qux_item.parameter_declarations[:domain_0][0])
        ]
        expect(component.parameter_declarations(:domain_1)).to match [
          eql(foo_item.parameter_declarations[:domain_1][0]),
          eql(bar_item.parameter_declarations[:domain_1][0]),
          eql(baz_item.parameter_declarations[:domain_1][0]),
          eql(qux_item.parameter_declarations[:domain_1][0]),
          eql(qux_item.parameter_declarations[:domain_1][1])
        ]
      end
    end
  end
end
