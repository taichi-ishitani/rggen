require_relative  '../spec_helper'

module RGen::RegisterMap
  describe "register_map/component_factory" do
    include_context 'bit_field sample factories'
    include_context 'register sample factories'
    include_context 'register_block sample factories'
    include_context 'register_map sample factory'

    let(:configuration) do
      get_component_class(:configuration, 0).new
    end

    let(:register_map_class) do
      get_component_class(:register_map, 0)
    end

    let(:valid_loader) do
      m = map
      Class.new(RGen::InputBase::Loader) do
        self.supported_types  = [:csv]
        define_method(:load_file) do |file|
          m
        end
      end
    end

    let(:invalid_loader) do
      d = invalid_data
      Class.new(RGen::InputBase::Loader) do
        self.supported_types  = [:txt]
        define_method(:load_file) do |file|
          d
        end
      end
    end

    let(:map) do
      create_map({
        "foo" => [
          [nil, "foo"   , :foo_0  , nil       , nil       ],
          [nil, "bar"   , :bar_0  , nil       , nil       ],
          [nil, nil     , nil     , nil       , nil       ],
          [nil, "foo"   , "bar"   , "foo"     , "bar"     ],
          [nil, :foo_0_0, :bar_0_0, :foo_0_0_0, :bar_0_0_0],
          [nil, nil     , nil     , :foo_0_0_1, :bar_0_0_1]
        ],
        "bar" => [
          [nil, "foo"   , :foo_1  , nil       , nil       ],
          [nil, "bar"   , :bar_1  , nil       , nil       ],
          [nil, nil     , nil     , nil       , nil       ],
          [nil, "foo"   , "bar"   , "foo"     , "bar"     ],
          [nil, :foo_1_0, :bar_1_0, :foo_1_0_0, :bar_1_0_0],
          [nil, :foo_1_1, :bar_1_1, :foo_1_1_0, :bar_1_1_0]
        ]
      })
    end

    let(:invalid_data) do
      ["foo", "bar"]
    end

    before do
      register_map_factory.loaders  = [valid_loader, invalid_loader]
    end

    describe "#create" do
      let(:register_map) do
        register_map_factory.create(configuration, file)
      end

      context "ロード結果がGenricMapのとき" do
        let(:file) do
          "foo.csv"
        end

        it "レジスタマップオブジェクトを生成する" do
          expect(register_map).to be_kind_of register_map_class
        end

        specify "生成されたレジスタマップオブジェクトは適切な値を持つレジスタブロックを持つ" do
          expect(register_map.register_blocks).to match([
            match_register_block(register_map, foo: :foo_0, bar: :bar_0),
            match_register_block(register_map, foo: :foo_1, bar: :bar_1),
          ])
        end

        specify "配下のレジスタブロックオブジェクトは適切な値を持つレジスタオブジェクトを持つ" do
          expect(register_map.register_blocks[0].registers).to match([
            match_register(register_map.register_blocks[0], foo: :foo_0_0, bar: :bar_0_0)
          ])
          expect(register_map.register_blocks[1].registers).to match([
            match_register(register_map.register_blocks[1], foo: :foo_1_0, bar: :bar_1_0),
            match_register(register_map.register_blocks[1], foo: :foo_1_1, bar: :bar_1_1)
          ])
        end

        specify "配下のレジスタオブジェクトは適切な値を持つビットフィールドオブジェクトを持つ" do
          expect(register_map.register_blocks[0].registers[0].bit_fields).to match([
            match_bit_field(register_map.register_blocks[0].registers[0], foo: :foo_0_0_0, bar: :bar_0_0_0),
            match_bit_field(register_map.register_blocks[0].registers[0], foo: :foo_0_0_1, bar: :bar_0_0_1)
          ])
          expect(register_map.register_blocks[1].registers[0].bit_fields).to match([
            match_bit_field(register_map.register_blocks[1].registers[0], foo: :foo_1_0_0, bar: :bar_1_0_0)
          ])
          expect(register_map.register_blocks[1].registers[1].bit_fields).to match([
            match_bit_field(register_map.register_blocks[1].registers[1], foo: :foo_1_1_0, bar: :bar_1_1_0)
          ])
        end
      end

      context "ロード結果がGenericMapではないとき" do
        let(:file) do
          "foo.txt"
        end

        it "LoadErrorを発生させる" do
          message = "GenericMap type required for register map: #{invalid_data.class}"
          expect{register_map_factory.create(configuration, file)}.to raise_load_error message
        end
      end
    end
  end
end
