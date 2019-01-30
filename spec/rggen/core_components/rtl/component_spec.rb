require_relative '../../../spec_helper'

module RgGen::RTL
  describe Component do
    def create_item(owner, &body)
      i = Class.new(Item, &body).new(owner)
      i.build
      i
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
        c = Component.new(component, configuration, register_map)
        component.add_child(c)
        c
      end
    end

    let(:foo_item) do
      create_item(component) do
        build do
          wire      :domain_a, :foo_wire
          reg       :domain_b, :foo_reg
          logic     :domain_a, :foo_logic
          input     :domain_b, :foo_input
          output    :domain_a, :foo_output
          parameter :domain_b, :foo_parameter
        end
      end
    end

    let(:bar_item) do
      create_item(children[0]) do
        build do
          wire      :domain_a, :bar_wire
          reg       :domain_b, :bar_reg
          logic     :domain_a, :bar_logic
          input     :domain_b, :bar_input
          output    :domain_a, :bar_output
          parameter :domain_b, :bar_parameter
        end
      end
    end

    let(:baz_item) do
      create_item(children[1]) do
        build do
          wire      :domain_a, :baz_reg
          logic     :domain_b, :baz_logic
          input     :domain_a, :baz_input
          output    :domain_b, :baz_output
          parameter :domain_a, :baz_parameter
        end
      end
    end

    describe "#build" do
      before do
        component.add_item(items[0])
        component.add_item(items[1])
        component.build
      end

      let(:items) do
        [
          create_item(component) {
            build do
              wire :domain_a, :foo
            end
          },
          create_item(component) {
            build do
              input   :domain_a, :bar
              output  :domain_a, :baz
            end
          }
        ]
      end

      it "アイテムオブジェクトが持つIdentifierオブジェクトへのアクセッサを定義する" do
        expect(component.foo).to eql items[0].foo
        expect(component.bar).to eql items[1].bar
        expect(component.baz).to eql items[1].baz
      end
    end

    describe "#signal_declarations" do
      before do
        component.add_item(foo_item)
        component.add_item(bar_item)
        children[0].add_item(baz_item)
      end

      let(:declarations) do
        Hash.new do |h, d|
          [foo_item, bar_item, baz_item].flat_map { |i| i.signal_declarations(d) }
        end
      end

      it "配下のアイテムオブジェクトが持つSignalDeclarationオブジェクトを返す" do
        expect(component.signal_declarations(:domain_a)).to match(declarations[:domain_a].map {|d| eql(d)})
        expect(component.signal_declarations(:domain_b)).to match(declarations[:domain_b].map {|d| eql(d)})
      end
    end

    describe "#port_declarations" do
      before do
        component.add_item(foo_item)
        component.add_item(bar_item)
        children[0].add_item(baz_item)
      end

      let(:declarations) do
        Hash.new do |h, d|
          [foo_item, bar_item, baz_item].flat_map { |i| i.port_declarations(d) }
        end
      end

      it "配下のアイテムオブジェクトが持つPortDeclarationオブジェクトを返す" do
        expect(component.port_declarations(:domain_a)).to match(declarations[:domain_a].map {|d| eql(d)})
        expect(component.port_declarations(:domain_b)).to match(declarations[:domain_b].map {|d| eql(d)})
      end
    end

    describe "#parameter_declarations" do
      before do
        component.add_item(foo_item)
        component.add_item(bar_item)
        children[0].add_item(baz_item)
      end

      let(:declarations) do
        Hash.new do |h, d|
          [foo_item, bar_item, baz_item].flat_map { |i| i.parameter_declarations(d) }
        end
      end

      it "配下のアイテムオブジェクトが持つParameterDeclarationオブジェクトを返す" do
        expect(component.parameter_declarations(:domain_a)).to match(declarations[:domain_a].map {|d| eql(d)})
        expect(component.parameter_declarations(:domain_b)).to match(declarations[:domain_b].map {|d| eql(d)})
      end
    end
  end
end
