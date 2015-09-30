require_relative '../spec_helper'

describe 'type/bit_field' do
  include_context 'register_map common'
  include_context 'configuration common'

  before(:all) do
    RGen.list_item(:bit_field, :type, :foo) do
      register_map {read_write}
    end
    RGen.list_item(:bit_field, :type, :bar) do
      register_map {read_only}
    end
    RGen.list_item(:bit_field, :type, :baz) do
      register_map {write_only}
    end
    RGen.list_item(:bit_field, :type, :qux) do
      register_map {reserved}
    end
    RGen.list_item(:bit_field, :type, :quux) do
      register_map {required_width 2}
    end
    RGen.list_item(:bit_field, :type, :foobar) do
      register_map {reserved}
    end

    RGen.enable(:global, :data_width)
    RGen.enable(:register_block, :name)
    RGen.enable(:register, :name)
    RGen.enable(:bit_field, [:name, :bit_assignment, :type])
    RGen.enable(:bit_field, :type, [:foo, :bar, :baz, :qux, :quux])
    @factory  = build_register_map_factory
  end

  before(:all) do
    @configuration_factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
    clear_dummy_types
  end

  let(:configuration) do
    ConfigurationDummyLoader.load_data({})
    @configuration_factory.create(configuration_file)
  end

  let(:bit_fields) do
    set_load_data(load_data)
    @factory.create(configuration, register_map_file).bit_fields
  end

  def register_map_data(data)
    all_data  = [
      [nil, nil, "block_0", nil, nil],
      [nil, nil, nil      , nil, nil],
      [nil, nil, nil      , nil, nil]
    ]
    all_data.concat(data)
    all_data
  end

  def set_load_data(data)
    all_data  = [
      [nil, nil, "block_0", nil, nil],
      [nil, nil, nil      , nil, nil],
      [nil, nil, nil      , nil, nil]
    ]
    all_data.concat(data)
    RegisterMapDummyLoader.load_data("block_0" => all_data)
  end

  def clear_dummy_types
    RGen.builder.categories.each_value do |category|
      category.instance_variable_get(:@item_stores).each_value do |item_store|
        entry = item_store.instance_variable_get(:@list_item_entries)[:type]
        next if entry.nil?
        entry.instance_variable_get(:@items).delete(:foo)
        entry.instance_variable_get(:@items).delete(:bar)
        entry.instance_variable_get(:@items).delete(:baz)
        entry.instance_variable_get(:@items).delete(:qux)
      end
    end
  end

  describe "#type" do
    let(:load_data) do
      [
        [nil, "register_0", "bit_field_0_0", "[1]", "BAR"],
        [nil, nil         , "bit_field_0_1", "[0]", "foo"],
        [nil, "register_1", "bit_field_1_0", "[1]", "qUx"],
        [nil, nil         , "bit_field_1_1", "[0]", "BaZ"]
      ]
    end

    it "小文字化されたタイプ名を返す" do
      expect(bit_fields.map(&:type)).to match [:bar, :foo, :qux, :baz]
    end
  end

  describe ".read_write" do
    let(:load_data) do
      [[nil, "register_0", "bit_field_0_0", "[0]", "foo"]]
    end

    it "アクセス属性をread-writeに設定する" do
      expect(bit_fields[0]).to match_access(:read_write)
    end
  end

  describe ".read_only" do
    let(:load_data) do
      [[nil, "register_0", "bit_field_0_0", "[0]", "bar"]]
    end

    it "アクセス属性をread-onlyに設定する" do
      expect(bit_fields[0]).to match_access(:read_only)
    end
  end

  describe ".write_only" do
    let(:load_data) do
      [[nil, "register_0", "bit_field_0_0", "[0]", "baz"]]
    end

    it "アクセス属性をwrite-onlyに設定する" do
      expect(bit_fields[0]).to match_access(:write_only)
    end
  end

  describe ".reserved" do
    let(:load_data) do
      [[nil, "register_0", "bit_field_0_0", "[0]", "qux"]]
    end

    it "アクセス属性をreservedに設定する" do
      expect(bit_fields[0]).to match_access(:reserved)
    end
  end

  describe ".required_width" do
    context ".required_widthで必要なビット幅が設定されていない場合" do
      before do
        RegisterMapDummyLoader.load_data("block_0" => register_map_data(load_data))
      end

      let(:load_data) do
        [
          [nil, "register_0", "bit_field_0_0", "[15:8]", "foo"],
          [nil, nil         , "bit_field_0_1", "[0]"   , "foo"],
          [nil, "register_1", "bit_field_1_0", "[31:0]", "foo"]
        ]
      end

      it "任意の幅のビットフィールドで使用できる" do
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error
      end
    end

    context "必要なビット幅が設定されている場合" do
      it "設定したビット幅を持つビットフィールドで使用できる" do
        set_load_data([
          [nil, "register_0", "bit_field_0_0", "[17:16]", "quux"],
          [nil, nil         , "bit_field_0_1", "[1:0]"  , "quux"]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error
      end

      context "設定した幅以外のビットフィールドで使用した場合" do
        it "RegisterMapErrorを発生させる" do
          {1 => "[0]", 3 => "[2:0]", 32 => "[31:0]"}.each do |width, assignment|
            set_load_data([[nil, "register_0", "bit_field_0_0", assignment, "quux"]])
            expect {
              @factory.create(configuration, register_map_file)
            }.to raise_register_map_error("2 bit(s) width required: #{width} bit(s)", position("block_0", 3, 4))
          end
        end
      end
    end
  end

  context "Rgen.enableで有効にされたタイプ以外が入力された場合" do
    it "RegisterMapErrorを発生させる" do
      ["foobar", "abc"].each do |type|
        set_load_data([[nil, "register_0", "bit_field_0_0", "[0]", type]])
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error("unknown bit field type: #{type}", position("block_0", 3, 4))
      end
    end
  end
end
