require_relative '../spec_helper'

describe 'register/type' do
  include_context 'register common'
  include_context 'configuration common'

  before(:all) do
    @items  = [:foo, :bar, :baz].each_with_object({}) do |item_name, items|
      list_item(:register, :type, item_name) do
        register_map { items[item_name] = self }
      end
    end

    enable :register_block, [:name, :byte_size]
    enable :register, [:name, :offset_address, :array, :shadow, :type]
    enable :register, :type, [:foo, :bar]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :wo, :reserved]

    @factory  = build_register_map_factory
  end

  before(:all) do
    enable :global, [:data_width, :address_width]
    ConfigurationDummyLoader.load_data({})
    @configuration  = build_configuration_factory.create(configuration_file)
  end

  after(:all) do
    clear_enabled_items
    clear_dummy_list_items(:type, [:foo, :bar, :baz])
  end

  after do
    @items.each_value do |item|
      [:@readability_evaluator, :@writability_evaluator, :@no_bit_fields].each do |variable|
        if item.instance_variable_defined?(variable)
          item.remove_instance_variable(variable)
        end
      end
    end
  end

  let(:configuration) do
    @configuration
  end

  def define_item(item_name, &body)
    @items[item_name].class_eval(&body)
  end

  describe "item_base" do
    describe "#type/#type?" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, nil, "bar", "bit_field_1_0", "[0]", :rw, 0, nil]
        ]
      end

      it "レジスタの型名を返す" do
        expect(registers[0].type).to eq :foo
        expect(registers[1].type).to eq :bar
      end

      it "与えた型名が自分の型名と同じかどうかを返す" do
        expect(registers[0]).to be_type(:foo)
        expect(registers[0]).not_to be_type(:bar)
      end
    end

    describe ".readable?/#readable?" do
      context ".readable?で評価ブロックが設定されていない場合" do
        let(:load_data) do
          [
            [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ]
        end

        specify "対象レジスタは読み出し可能" do
          expect(registers[0]).to be_readable
        end
      end

      context ".readable?で評価ブロックが設定されている場合" do
        let(:load_data) do
          [
            [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
            [nil, "register_1", "0x04", nil, nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil]
          ]
        end

        before do
          define_item(:foo) { readable? { register.start_address == 0 } }
        end

        it "ブロックをアイテムのコンテキストで評価した結果が、レジスタの読み出し可能性" do
          expect(registers[0]).to be_readable
          expect(registers[1]).not_to be_readable
        end
      end
    end

    describe ".writable?/#writable?" do
      context ".writable?で評価ブロックが設定されていない場合" do
        let(:load_data) do
          [
            [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ]
        end

        specify "対象レジスタは書き込み可能" do
          expect(registers[0]).to be_writable
        end
      end

      context ".writable?で評価ブロックが設定されている場合" do
        let(:load_data) do
          [
            [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
            [nil, "register_1", "0x04", nil, nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil]
          ]
        end

        before do
          define_item(:foo) { writable? { register.start_address == 0 } }
        end

        specify "ブロックをアイテムのコンテキストで評価した結果が、レジスタの書き込み可能性" do
          expect(registers[0]).to be_writable
          expect(registers[1]).not_to be_writable
        end
      end
    end

    describe "#read_only?" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil]
        ]
      end

      before do
        define_item(:foo) { writable? { register.start_address != 0 } }
      end

      it "読み込みのみ可能かどうかを示す" do
        expect(registers[0]).to be_read_only
        expect(registers[1]).not_to be_read_only
      end
    end

    describe "#write_only?" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil]
        ]
      end

      before do
        define_item(:foo) { readable? { register.start_address != 0 } }
      end

      it "書き込みのみ可能かどうかを示す" do
        expect(registers[0]).to be_write_only
        expect(registers[1]).not_to be_write_only
      end
    end

    describe "#reserved?" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil],
          [nil, "register_2", "0x08", nil, nil, "foo", "bit_field_2_0", "[0]", :rw, 0, nil],
          [nil, "register_3", "0x0C", nil, nil, "foo", "bit_field_3_0", "[0]", :rw, 0, nil]
        ]
      end

      before do
        define_item(:foo) do
          readable? { register.start_address[2] != 0 }
          writable? { register.start_address[3] != 0 }
        end
      end

      it "予約済みであるかを示す" do
        expect(registers[0]).to be_reserved
        expect(registers[1]).not_to be_reserved
        expect(registers[2]).not_to be_reserved
        expect(registers[3]).not_to be_reserved
      end
    end

    describe ".read_write" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
        ]
      end

      before do
        define_item(:foo) { read_write }
      end

      it "対象レジスタが読み書き可能であることを指定する" do
        expect(registers[0]).to be_readable.and be_writable
      end
    end

    describe ".read_only" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
        ]
      end

      before do
        define_item(:foo) { read_only }
      end

      it "対象レジスタが読み出しのみ可能であることを指定する" do
        expect(registers[0]).to be_read_only
      end
    end

    describe ".write_only" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
        ]
      end

      before do
        define_item(:foo) { write_only }
      end

      it "対象レジスタが書き込みのみ可能であることを指定する" do
        expect(registers[0]).to be_write_only
      end
    end

    describe ".reserved" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
        ]
      end

      before do
        define_item(:foo) { reserved }
      end

      it "対象レジスタが予約済みであることを指定する" do
        expect(registers[0]).to be_reserved
      end
    end

    describe ".need_no_bit_fields" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, nil, "bar", "bit_field_1_0", "[0]", :rw, 0, nil]
        ]
      end

      before do
        define_item(:foo) { need_no_bit_fields }
      end

      it "対象レジスタがビットフィールドを含まないことを指定する" do
        expect(registers[0].bit_fields).to be_empty
        expect(registers[1].bit_fields).not_to be_empty
      end
    end
  end

  describe "default_item" do
    describe "#type" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", :rw, 0, nil],
        ]
      end

      it ":defaultを返す" do
        expect(registers[0].type).to eq :default
      end
    end

    describe "#readable?" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", :rw      , 0, nil],
          [nil, "register_1", "0x04", nil, nil, nil, "bit_field_1_0", "[0]", :ro      , 0, nil],
          [nil, "register_2", "0x08", nil, nil, nil, "bit_field_2_0", "[1]", :ro      , 0, nil],
          [nil, nil         , nil   , nil, nil, nil, "bit_field_2_1", "[0]", :wo      , 0, nil],
          [nil, "register_3", "0x0C", nil, nil, nil, "bit_field_3_0", "[0]", :wo      , 0, nil],
          [nil, "register_4", "0x10", nil, nil, nil, "bit_field_4_0", "[0]", :reserved, 0, nil]
        ]
      end

      it "配下のビットフィールドが読み出し可能かどうかを示す" do
        expect(registers[0]).to be_readable
        expect(registers[1]).to be_readable
        expect(registers[2]).to be_readable
        expect(registers[3]).not_to be_readable
        expect(registers[4]).not_to be_readable
      end
    end

    describe "#writable?" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", :rw      , 0, nil],
          [nil, "register_1", "0x04", nil, nil, nil, "bit_field_1_0", "[0]", :wo      , 0, nil],
          [nil, "register_2", "0x08", nil, nil, nil, "bit_field_2_0", "[1]", :wo      , 0, nil],
          [nil, nil         , nil   , nil, nil, nil, "bit_field_2_1", "[0]", :ro      , 0, nil],
          [nil, "register_3", "0x0C", nil, nil, nil, "bit_field_3_0", "[0]", :ro      , 0, nil],
          [nil, "register_4", "0x10", nil, nil, nil, "bit_field_4_0", "[0]", :reserved, 0, nil]
        ]
      end

      it "配下のビットフィールドが書き込み可能かどうかを示す" do
        expect(registers[0]).to be_writable
        expect(registers[1]).to be_writable
        expect(registers[2]).to be_writable
        expect(registers[3]).not_to be_writable
        expect(registers[4]).not_to be_writable
      end
    end

    describe "#bit_fiels" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, nil, "bit_field_0_0", "[0]", :rw, 0, nil],
        ]
      end

      it "配下にビットフィールドを持つ" do
        expect(registers[0].bit_fields).not_to be_empty
      end
    end
  end

  describe "factory" do
    context "入力が空セルの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, nil  , "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, nil, ""   , "bit_field_1_0", "[0]", :rw, 0, nil]
        ]
      end

      it "デフォルトのレジスタを生成する" do
        expect(registers.map(&:type)).to all(eq :default)
      end
    end

    context "入力がdefaultの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, :default , "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, nil, "default", "bit_field_1_0", "[0]", :rw, 0, nil],
          [nil, "register_2", "0x08", nil, nil, :DEFAULT , "bit_field_2_0", "[0]", :rw, 0, nil],
          [nil, "register_3", "0x0C", nil, nil, "DEFAULT", "bit_field_3_0", "[0]", :rw, 0, nil]
        ]
      end

      it "デフォルトのレジスタを生成する" do
        expect(registers.map(&:type)).to all(eq :default)
      end
    end

    context "入力がenableで有効したレジスタ型の場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, :foo , "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil],
          [nil, "register_2", "0x08", nil, nil, :BAR , "bit_field_2_0", "[0]", :rw, 0, nil],
          [nil, "register_3", "0x0C", nil, nil, "BAR", "bit_field_3_0", "[0]", :rw, 0, nil]
        ]
      end

      it "指定した型のレジスタを生成する" do
        expect(registers[0].type).to eq :foo
        expect(registers[1].type).to eq :foo
        expect(registers[2].type).to eq :bar
        expect(registers[3].type).to eq :bar
      end
    end

    context "それ以外の入力の場合" do
      let(:invalid_values) do
        [:baz, :foo_bar, " ", "\t"]
      end

      it "RgGen::RegisterMapErrorを発生させる" do
        invalid_values.each do |invalid_value|
          set_load_data([
            [nil, "register_0", "0x00", nil, nil, invalid_value, "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("unknown register type: #{invalid_value}", position("block_0", 4, 5))
        end
      end
    end
  end
end
