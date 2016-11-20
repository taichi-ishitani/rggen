require_relative '../../spec_helper'

module RgGen::OutputBase
  describe Component do
    def create_component(parent)
      Component.new(parent, configuration, register_map).tap do |c|
        parent && parent.add_child(c)
      end
    end

    def create_item(owner, &body)
      Class.new(Item, &body).new(owner).tap { |item| owner.add_item(item) }
    end

    let(:component) do
      create_component(nil)
    end

    let(:child_components) do
      2.times.map do
        create_component(component)
      end
    end

    let(:grandchild_components) do
      4.times.map do |i|
        create_component(child_components[i / 2])
      end
    end

    let(:configuration) do
      RgGen::InputBase::Component.new(nil)
    end

    let(:register_map) do
      RgGen::InputBase::Component.new(nil)
    end

    it "階層アクセッサを持つ" do
      expect(component.hierarchy                   ).to     eq :register_map
      expect(child_components.map(&:hierarchy)     ).to all(eq :register_block)
      expect(grandchild_components.map(&:hierarchy)).to all(eq :register      )
    end

    it "自身をレシーバとして、配下のアイテムのexportされたメソッドを呼び出せる" do
      create_item(component) do
        export :foo
      end
      create_item(component) do
        export :bar
      end
      expect(component.items[0]).to receive(:foo)
      expect(component.items[1]).to receive(:bar)
      component.foo
      component.bar
    end

    it "自身をレシーバとして、与えられたレジスタマップオブジェクトの各フィールドにアクセスできる" do
      allow(register_map).to receive(:fields).and_return([:foo, :bar])
      expect(register_map).to receive(:foo)
      expect(register_map).to receive(:bar)
      component.foo
      component.bar
    end

    describe "#need_children?" do
      context "レジスタマップオブジェクトが子コンポーネントを必要とする場合" do
        it "同様に子コンポーネントを必要とする" do
          expect(component.need_children?).to be true
        end
      end

      context "レジスタマップオブジェクトが子コンポーネントを必要としない場合" do
        before do
          register_map.need_no_children
        end

        it "同様に子コンポーネントを必要としない" do
          expect(component.need_children?).to be false
        end
      end
    end

    describe "#configuration" do
      it "与えられたコンフィグレーションオブジェクトを返す" do
        expect(component.configuration).to be configuration
      end
    end

    describe "#source" do
      it "与えられたレジスタマップオブジェクトを返す" do
        expect(component.source).to be register_map
      end
    end

    describe "#build" do
      before do
        allow(Item).to receive(:new).and_wrap_original do |m, *args|
          m.call(*args).tap { |item| expect(item).to receive(:build) }
        end

        create_item(component) {}
        create_item(component) {}

        child_components.each do |child_component|
          create_item(child_component) {}
          create_item(child_component) {}
        end

        grandchild_components.each do |grandchild_component|
          create_item(grandchild_component) {}
          create_item(grandchild_component) {}
        end
      end

      it "配下の全アイテムの#buildを呼び出す" do
        component.build
      end
    end

    describe "#generate_code" do
      before do
        allow_any_instance_of(Item).to receive(:create_blank_code).and_return(code)
      end

      before do
        create_item(component) { generate_code(:foo) { "#{owner.object_id}_foo" } }
        create_item(component) { generate_code(:bar) { "#{owner.object_id}_bar" } }

        child_components.each do |child_component|
          create_item(child_component) { generate_code(:foo) { "#{owner.object_id}_foofoo" } }
          create_item(child_component) { generate_code(:bar) { "#{owner.object_id}_barbar" } }
        end

        grandchild_components.each do |grandchild_component|
          create_item(grandchild_component) { generate_code(:foo) { "#{owner.object_id}_foofoofoo" } }
          create_item(grandchild_component) { generate_code(:bar) { "#{owner.object_id}_barbarbar" } }
        end
      end

      let(:code) do
        double("code")
      end

      def expected_code(code_or_code_array)
        Array(code_or_code_array).each do |c|
          expect(code).to receive(:<<).with(c).ordered
        end
      end

      it "使用した、または、内部で生成したコードオブジェクトを返す" do
        allow(code).to receive(:<<)
        expect(component.generate_code(:foo, :top_down, code)).to be code
        expect(component.generate_code(:foo, :top_down      )).to be code
      end

      context "modeが:top_downを指定した場合" do
        it "kindで指定した種類のコードを上位から生成する" do
          expected_code [
            "#{component.object_id}_foo",
            "#{child_components[0].object_id}_foofoo",
            "#{grandchild_components[0].object_id}_foofoofoo",
            "#{grandchild_components[1].object_id}_foofoofoo",
            "#{child_components[1].object_id}_foofoo",
            "#{grandchild_components[2].object_id}_foofoofoo",
            "#{grandchild_components[3].object_id}_foofoofoo"
          ]
          component.generate_code(:foo, :top_down, code)

          expected_code [
            "#{component.object_id}_bar",
            "#{child_components[0].object_id}_barbar",
            "#{grandchild_components[0].object_id}_barbarbar",
            "#{grandchild_components[1].object_id}_barbarbar",
            "#{child_components[1].object_id}_barbar",
            "#{grandchild_components[2].object_id}_barbarbar",
            "#{grandchild_components[3].object_id}_barbarbar"
          ]
          component.generate_code(:bar, :top_down)
        end
      end

      context "modeが:bottom_upを指定した場合" do
        it "kindで指定した種類のコードを下位から生成する" do
          expected_code [
            "#{grandchild_components[0].object_id}_foofoofoo",
            "#{grandchild_components[1].object_id}_foofoofoo",
            "#{child_components[0].object_id}_foofoo",
            "#{grandchild_components[2].object_id}_foofoofoo",
            "#{grandchild_components[3].object_id}_foofoofoo",
            "#{child_components[1].object_id}_foofoo",
            "#{component.object_id}_foo"
          ]
          component.generate_code(:foo, :bottom_up, code)

          expected_code [
            "#{grandchild_components[0].object_id}_barbarbar",
            "#{grandchild_components[1].object_id}_barbarbar",
            "#{child_components[0].object_id}_barbar",
            "#{grandchild_components[2].object_id}_barbarbar",
            "#{grandchild_components[3].object_id}_barbarbar",
            "#{child_components[1].object_id}_barbar",
            "#{component.object_id}_bar"
          ]
          component.generate_code(:bar, :bottom_up)
        end
      end

      context "Item.generate_pre_codeで事前コード生成が登録されている場合" do
        before do
          create_item(component) do
            generate_pre_code(:foo) { "#{owner.object_id}_pre_foo" }
            generate_pre_code(:bar) { "#{owner.object_id}_pre_bar" }
          end

          child_components.each do |child_component|
            create_item(child_component) do
              generate_pre_code(:foo) { "#{owner.object_id}_pre_foofoo" }
              generate_pre_code(:bar) { "#{owner.object_id}_pre_barbar" }
            end
          end
        end

        it "generaet_codeで登録されたコードの前に、指定された種類の事前コードを挿入する" do
          expected_code [
            "#{component.object_id}_pre_foo",
            "#{component.object_id}_foo",
            "#{child_components[0].object_id}_pre_foofoo",
            "#{child_components[0].object_id}_foofoo",
            "#{grandchild_components[0].object_id}_foofoofoo",
            "#{grandchild_components[1].object_id}_foofoofoo",
            "#{child_components[1].object_id}_pre_foofoo",
            "#{child_components[1].object_id}_foofoo",
            "#{grandchild_components[2].object_id}_foofoofoo",
            "#{grandchild_components[3].object_id}_foofoofoo"
          ]
          component.generate_code(:foo, :top_down, code)

          expected_code [
            "#{component.object_id}_pre_bar",
            "#{child_components[0].object_id}_pre_barbar",
            "#{grandchild_components[0].object_id}_barbarbar",
            "#{grandchild_components[1].object_id}_barbarbar",
            "#{child_components[0].object_id}_barbar",
            "#{child_components[1].object_id}_pre_barbar",
            "#{grandchild_components[2].object_id}_barbarbar",
            "#{grandchild_components[3].object_id}_barbarbar",
            "#{child_components[1].object_id}_barbar",
            "#{component.object_id}_bar"
          ]
          component.generate_code(:bar, :bottom_up, code)
        end
      end

      context "Item.generate_post_codeで事後コード生成が登録されている場合" do
        before do
          create_item(component) do
            generate_post_code(:foo) { "#{owner.object_id}_post_foo" }
            generate_post_code(:bar) { "#{owner.object_id}_post_bar" }
          end

          child_components.each do |child_component|
            create_item(child_component) do
              generate_post_code(:foo) { "#{owner.object_id}_post_foofoo" }
              generate_post_code(:bar) { "#{owner.object_id}_post_barbar" }
            end
          end
        end

        it "generaet_codeで登録されたコードの後に、指定された種類の事後コードを挿入する" do
          expected_code [
            "#{component.object_id}_foo",
            "#{child_components[0].object_id}_foofoo",
            "#{grandchild_components[0].object_id}_foofoofoo",
            "#{grandchild_components[1].object_id}_foofoofoo",
            "#{child_components[0].object_id}_post_foofoo",
            "#{child_components[1].object_id}_foofoo",
            "#{grandchild_components[2].object_id}_foofoofoo",
            "#{grandchild_components[3].object_id}_foofoofoo",
            "#{child_components[1].object_id}_post_foofoo",
            "#{component.object_id}_post_foo"
          ]
          component.generate_code(:foo, :top_down, code)

          expected_code [
            "#{grandchild_components[0].object_id}_barbarbar",
            "#{grandchild_components[1].object_id}_barbarbar",
            "#{child_components[0].object_id}_barbar",
            "#{child_components[0].object_id}_post_barbar",
            "#{grandchild_components[2].object_id}_barbarbar",
            "#{grandchild_components[3].object_id}_barbarbar",
            "#{child_components[1].object_id}_barbar",
            "#{child_components[1].object_id}_post_barbar",
            "#{component.object_id}_bar",
            "#{component.object_id}_post_bar"
          ]
          component.generate_code(:bar, :bottom_up, code)
        end
      end
    end

    describe "#write_file" do
      before do
        allow(Item).to receive(:new).and_wrap_original do |m, *args|
          m.call(*args).tap do |item|
            expect(item).to receive(:write_file).with([root_directory, output_directory])
          end
        end

        component.output_directory  = output_directory

        create_item(component)
        create_item(component)

        child_components.each do |child_component|
          create_item(child_component)
          create_item(child_component)
        end

        grandchild_components.each do |grandchild__component|
          create_item(grandchild__component)
          create_item(grandchild__component)
        end
      end

      let(:root_directory) do
        'foo/bar'
      end

      let(:output_directory) do
        'baz'
      end

      it "与えられた出力ディレクトリ/@output_directoryを引数として、配下全アイテムオブジェクトの#write_fileを呼び出す" do
        component.write_file(root_directory)
      end
    end
  end
end
