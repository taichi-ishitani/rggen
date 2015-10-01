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
    RGen.list_item(:bit_field, :type, :corge) do
      register_map {use_reference}
    end
    RGen.list_item(:bit_field, :type, :grault) do
      register_map {use_reference required:false, width:2}
    end
    RGen.list_item(:bit_field, :type, :garply) do
      register_map {use_reference required:true, width:same_width}
    end
    RGen.list_item(:bit_field, :type, :foobar) do
      register_map {reserved}
    end

    RGen.enable(:global, :data_width)
    RGen.enable(:register_block, :name)
    RGen.enable(:register, :name)
    RGen.enable(:bit_field, [:name, :bit_assignment, :type, :reference])
    RGen.enable(:bit_field, :type, [:foo, :bar, :baz, :qux, :quux, :corge, :grault, :garply])
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

  def set_load_data(data)
    all_data  = [
      [nil, nil, "block_0"],
      [nil, nil, nil      ],
      [nil, nil, nil      ]
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
        [nil, "register_0", "bit_field_0_0", "[1]", "BAR", nil],
        [nil, nil         , "bit_field_0_1", "[0]", "foo", nil],
        [nil, "register_1", "bit_field_1_0", "[1]", "qUx", nil],
        [nil, nil         , "bit_field_1_1", "[0]", "BaZ", nil]
      ]
    end

    it "小文字化されたタイプ名を返す" do
      expect(bit_fields.map(&:type)).to match [:bar, :foo, :qux, :baz]
    end
  end

  describe ".read_write" do
    let(:load_data) do
      [[nil, "register_0", "bit_field_0_0", "[0]", "foo", nil]]
    end

    it "アクセス属性をread-writeに設定する" do
      expect(bit_fields[0]).to match_access(:read_write)
    end
  end

  describe ".read_only" do
    let(:load_data) do
      [[nil, "register_0", "bit_field_0_0", "[0]", "bar", nil]]
    end

    it "アクセス属性をread-onlyに設定する" do
      expect(bit_fields[0]).to match_access(:read_only)
    end
  end

  describe ".write_only" do
    let(:load_data) do
      [[nil, "register_0", "bit_field_0_0", "[0]", "baz", nil]]
    end

    it "アクセス属性をwrite-onlyに設定する" do
      expect(bit_fields[0]).to match_access(:write_only)
    end
  end

  describe ".reserved" do
    let(:load_data) do
      [[nil, "register_0", "bit_field_0_0", "[0]", "qux", nil]]
    end

    it "アクセス属性をreservedに設定する" do
      expect(bit_fields[0]).to match_access(:reserved)
    end
  end

  describe ".required_width" do
    context ".required_widthで必要なビット幅が設定されていない場合" do
      it "任意の幅のビットフィールドで使用できる" do
        set_load_data([
          [nil, "register_0", "bit_field_0_0", "[15:8]", "foo", nil],
          [nil, nil         , "bit_field_0_1", "[0]"   , "foo", nil],
          [nil, "register_1", "bit_field_1_0", "[31:0]", "foo", nil]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error
      end
    end

    context "必要なビット幅が設定されている場合" do
      it "設定したビット幅を持つビットフィールドで使用できる" do
        set_load_data([
          [nil, "register_0", "bit_field_0_0", "[17:16]", "quux", nil],
          [nil, nil         , "bit_field_0_1", "[1:0]"  , "quux", nil]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error
      end

      context "設定した幅以外のビットフィールドで使用した場合" do
        it "RegisterMapErrorを発生させる" do
          {1 => "[0]", 3 => "[2:0]", 32 => "[31:0]"}.each do |width, assignment|
            set_load_data([[nil, "register_0", "bit_field_0_0", assignment, "quux", nil]])
            expect {
              @factory.create(configuration, register_map_file)
            }.to raise_register_map_error("2 bit(s) width required: #{width} bit(s)", position("block_0", 3, 4))
          end
        end
      end
    end
  end

  describe ".use_reference" do
    context ".use_referenceで参照信号設定がない場合" do
      it "任意の幅のビットフィールドで使用できる" do
        set_load_data([
          [nil, "register_0", "bit_field_0_0", "[15:8]", "foo", nil            ],
          [nil, nil         , "bit_field_0_1", "[0]"   , "foo", nil            ],
          [nil, "register_1", "bit_field_1_0", "[31:0]", "foo", "bit_field_0_0"]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error
      end
    end

    describe "requiredオプション" do
      context "オプションの指定がない場合" do
        it "参照ビットフィールドの指定に有無にかかわらず使用できる" do
          set_load_data([
            [nil, "register_0", "bit_field_0_0", "[1]", "corge", nil            ],
            [nil, nil         , "bit_field_0_1", "[0]", "corge", "bit_field_0_0"]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end
      end

      context "falseに設定されている場合" do
        it "参照ビットフィールドの指定に有無にかかわらず使用できる" do
          set_load_data([
            [nil, "register_0", "bit_field_0_0", "[3:2]", "grault", nil            ],
            [nil, nil         , "bit_field_0_1", "[1:0]", "grault", "bit_field_0_0"]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end
      end

      context "trueに設定されている場合" do
        it "参照ビットフィールドを持つビットフィールドで使用できる" do
          set_load_data([
            [nil, "register_0", "bit_field_0_0", "[7:4]", "foo"   , nil            ],
            [nil, nil         , "bit_field_0_1", "[3:0]", "garply", "bit_field_0_0"]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end

        context "参照信号を持たないビットフィールで使用した場合" do
          it "RGen::RegisterMapErrorを発生させる" do
            set_load_data([
              [nil, "register_0", "bit_field_0_0", "[7:4]", "garply", nil]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.to raise_error "reference bit field required", position("block_0", 3, 4)
          end
        end
      end
    end

    describe "widthオプション" do
      context "参照ビットフィールド幅の指定がない場合" do
        it "1ビットの参照ビットフィールドを持つビットフィールで使用できる" do
          set_load_data([
            [nil, "register_0", "bit_field_0_0", "[1]", "foo"  , nil            ],
            [nil, nil         , "bit_field_0_1", "[0]", "corge", "bit_field_0_0"]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end

        context "2ビット以上のビットフィールドを参照ビットフィールドに指定した場合" do
          it "RGen::RegisterMapErrorを発生させる" do
            set_load_data([
              [nil, "register_0", "bit_field_0_0", "[2:1]", "foo"  , nil            ],
              [nil, nil         , "bit_field_0_1", "[0]"  , "corge", "bit_field_0_0"]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.to raise_error "1 bit(s) reference bit field required: 2", position("block_0", 4, 4)
          end
        end
      end

      context "参照ビットフィールド幅が数字で指定された場合" do
        it "指定幅の参照ビットフィールドを持つビットフィールで使用できる" do
          set_load_data([
            [nil, "register_0", "bit_field_0_0", "[5:4]", "foo"   , nil            ],
            [nil, nil         , "bit_field_0_1", "[3:0]", "grault", "bit_field_0_0"]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end

        context "指定幅以外のビットフィールドを参照ビットフィールドに指定した場合" do
          it "RGen::RegisterMapErrorを発生させる" do
            {3 => "[6:4]", 1 => "[4]"}.each do |width, assigment|
              set_load_data([
                [nil, "register_0", "bit_field_0_0", assigment, "foo"   , nil            ],
                [nil, nil         , "bit_field_0_1", "[0]"    , "grault", "bit_field_0_0"]
              ])
              expect {
                @factory.create(configuration, register_map_file)
              }.to raise_error "2 bit(s) reference bit field required: #{width}", position("block_0", 4, 4)
            end
          end
        end
      end

      context "参照ビットフィールド幅が:same_widthで指定された場合" do
        it "同じ幅の参照ビットフィールドを持つビットフィールで使用できる" do
          set_load_data([
            [nil, "register_0", "bit_field_0_0", "[7:4]", "foo"   , nil            ],
            [nil, nil         , "bit_field_0_1", "[3:0]", "garply", "bit_field_0_0"]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end

        context "違う幅のビットフィールドを参照ビットフィールドに指定した場合" do
          it "RGen::RegisterMapErrorを発生させる" do
            {3 => "[6:4]", 1 => "[4]"}.each do |width, assigment|
              set_load_data([
                [nil, "register_0", "bit_field_0_0", assigment, "foo"   , nil            ],
                [nil, nil         , "bit_field_0_1", "[1:0]"  , "garply", "bit_field_0_0"]
              ])
              expect {
                @factory.create(configuration, register_map_file)
              }.to raise_error "2 bit(s) reference bit field required: #{width}", position("block_0", 4, 4)
            end
          end
        end
      end
    end
  end

  context "Rgen.enableで有効にされたタイプ以外が入力された場合" do
    it "RegisterMapErrorを発生させる" do
      ["foobar", "abc"].each do |type|
        set_load_data([[nil, "register_0", "bit_field_0_0", "[0]", type, nil]])
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error("unknown bit field type: #{type}", position("block_0", 3, 4))
      end
    end
  end
end
