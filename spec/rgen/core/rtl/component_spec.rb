require_relative '../../../spec_helper'

module RGen::Rtl
  describe Component do
    def create_item(owner, &body)
      i = Class.new(Item, &body).new(owner)
      i.build(nil, nil)
      i
    end

    let(:component) do
      Component.new(nil)
    end

    let(:children) do
      2.times.map do
        c = Component.new(component)
        component.add_child(c)
        c
      end
    end

    let(:foo_item) do
      create_item(component) do
        build do
          wire      :foo_wire
          reg       :foo_reg
          logic     :foo_logic
          input     :foo_input
          output    :foo_output
          parameter :foo_parameter
        end
      end
    end

    let(:bar_item) do
      create_item(component) do
        build do
          group(:bar_signals) do
            wire  :bar_wire
            reg   :bar_reg
            logic :bar_logic
          end
          group(:bar_ports) do
            input  :bar_input
            output :bar_output
          end
          group(:bar_parameters) do
            parameter :bar_parameter_0
            parameter :bar_parameter_1
          end
          group(:bar_localparams) do
            localparam :bar_localparam_0
            localparam :bar_localparam_1
          end
        end
      end
    end

    let(:baz_item) do
      create_item(children[0]) do
        build do
          wire      :baz_wire
          reg       :baz_reg
          logic     :baz_logic
          input     :baz_input
          output    :baz_output
          parameter :baz_parameter
        end
      end
    end

    let(:qux_item) do
      create_item(children[1]) do
        build do
          wire      :qux_wire
          reg       :qux_reg
          logic     :qux_logic
          input     :qux_input
          output    :qux_output
          parameter :qux_parameter
        end
      end
    end

    describe "#add_item" do
      before do
        component.add_item(item)
      end

      let(:item) do
        create_item(component) do
          build do
            wire :foo
            group(:bar_baz) do
              input   :bar
              output  :baz
            end
          end
        end
      end

      it "アイテムオブジェクトが持つIdentifierオブジェクトへのアクセッサを定義する" do
        expect(component.foo        ).to eql item.foo
        expect(component.bar_baz.bar).to eql item.bar_baz.bar
        expect(component.bar_baz.baz).to eql item.bar_baz.baz
      end
    end

    describe "#signal_declarations" do
      before do
        component.add_item(foo_item)
        component.add_item(bar_item)
        children[0].add_item(baz_item)
        children[1].add_item(qux_item)
      end

      let(:declarations) do
        [foo_item, bar_item, baz_item, qux_item].flat_map(&:signal_declarations)
      end

      it "配下のアイテムオブジェクトが持つSignalDeclarationオブジェクトを返す" do
        expect(component.signal_declarations).to match(declarations.map {|d| eql(d)})
      end
    end

    describe "#port_declarations" do
      before do
        component.add_item(foo_item)
        component.add_item(bar_item)
        children[0].add_item(baz_item)
        children[1].add_item(qux_item)
      end

      let(:declarations) do
        [foo_item, bar_item, baz_item, qux_item].flat_map(&:port_declarations)
      end

      it "配下のアイテムオブジェクトが持つPortDeclarationオブジェクトを返す" do
        expect(component.port_declarations).to match(declarations.map {|d| eql(d)})
      end
    end

    describe "#parameter_declarations" do
      before do
        component.add_item(foo_item)
        component.add_item(bar_item)
        children[0].add_item(baz_item)
        children[1].add_item(qux_item)
      end

      let(:declarations) do
        [foo_item, bar_item, baz_item, qux_item].flat_map(&:parameter_declarations)
      end

      it "配下のアイテムオブジェクトが持つParameterDeclarationオブジェクト(type:parameter)を返す" do
        expect(component.parameter_declarations).to match(declarations.map {|d| eql(d)})
      end
    end

    describe "#localparam_declarations" do
      before do
        component.add_item(foo_item)
        component.add_item(bar_item)
        children[0].add_item(baz_item)
        children[1].add_item(qux_item)
      end

      let(:declarations) do
        [foo_item, bar_item, baz_item, qux_item].flat_map(&:localparam_declarations)
      end

      it "配下のアイテムオブジェクトが持つParameterDeclarationオブジェクト(type:localparam)を返す" do
        expect(component.localparam_declarations).to match(declarations.map {|d| eql(d)})
      end
    end
  end
end
