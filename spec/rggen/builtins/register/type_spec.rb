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
    enable :register, [:name, :offset_address, :array, :type]
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
      [
        :@readability_evaluator,
        :@writability_evaluator,
        :@need_options,
        :@support_array_register,
        :@array_options,
        :@required_byte_size,
        :@no_bit_fields
      ].each do |variable|
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
    describe "#build" do
      before do
        define_item(:foo) do
          field :foo_type
          field :foo_options
          build do |cell|
            @foo_type     = cell.type
            @foo_options  = cell.options
          end
        end

        define_item(:bar) do
          field :bar_type
          field :bar_options
          build do |cell|
            @bar_type     = cell.type
            @bar_options  = cell.options
          end
        end
      end

      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, "foo"          , "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, "bar: baz "    , "bit_field_1_0", "[0]", :rw, 0, nil],
          [nil, "register_2", "0x08", nil, "bar: baz\nqux", "bit_field_2_0", "[0]", :rw, 0, nil]
        ]
      end

      it "ブロック内で入力された型名とオプションを参照できる" do
        expect(registers[0].foo_type   ).to eq :foo
        expect(registers[0].foo_options).to be_nil
        expect(registers[1].bar_type   ).to eq :bar
        expect(registers[1].bar_options).to eq " baz "
        expect(registers[2].bar_type   ).to eq :bar
        expect(registers[2].bar_options).to eq " baz\nqux"
      end
    end

    describe "#type/#type?" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, "bar", "bit_field_1_0", "[0]", :rw, 0, nil]
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
            [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ]
        end

        specify "対象レジスタは読み出し可能" do
          expect(registers[0]).to be_readable
        end
      end

      context ".readable?で評価ブロックが設定されている場合" do
        let(:load_data) do
          [
            [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
            [nil, "register_1", "0x04", nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil]
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
            [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ]
        end

        specify "対象レジスタは書き込み可能" do
          expect(registers[0]).to be_writable
        end
      end

      context ".writable?で評価ブロックが設定されている場合" do
        let(:load_data) do
          [
            [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
            [nil, "register_1", "0x04", nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil]
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
          [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil]
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
          [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil]
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
          [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil],
          [nil, "register_2", "0x08", nil, "foo", "bit_field_2_0", "[0]", :rw, 0, nil],
          [nil, "register_3", "0x0C", nil, "foo", "bit_field_3_0", "[0]", :rw, 0, nil]
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
          [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
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
          [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
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
          [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
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
          [nil, "register_0", "0x00", nil,  "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
        ]
      end

      before do
        define_item(:foo) { reserved }
      end

      it "対象レジスタが予約済みであることを指定する" do
        expect(registers[0]).to be_reserved
      end
    end

    describe ".need_options" do
      before do
        define_item(:bar) { need_options }
      end

      it "対象レジスタがオプションが必要かどうかを指定する" do
        set_load_data([
          [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error

        set_load_data([
          [nil, "register_0", "0x00", nil, "bar: baz", "bit_field_0_0", "[0]", :rw, 0, nil]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error

        set_load_data([
          [nil, "register_0", "0x00", nil, "bar", "bit_field_0_0", "[0]", :rw, 0, nil]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error("no options are specified", position("block_0", 4, 4))
      end
    end

    describe ".support_array_register" do
      before do
        define_item(:foo) { support_array_register }
      end

      it "対象レジスタが配列レジスタに対応しているかどうかを指定する" do
        set_load_data([
          [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error

        set_load_data([
          [nil, "register_0", "0x00", "[1]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error

        set_load_data([
          [nil, "register_0", "0x00", nil, "bar", "bit_field_0_0", "[0]", :rw, 0, nil]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.not_to raise_error

        set_load_data([
          [nil, "register_0", "0x00", "[1]", "bar", "bit_field_0_0", "[0]", :rw, 0, nil]
        ])
        expect {
          @factory.create(configuration, register_map_file)
        }.to raise_register_map_error("array register is not allowed", position("block_0", 4, 4))
      end

      describe "support_multiple_dimensionsオプション" do
        context "未指定の場合" do
          it "対象レジスタが単一次元の配列レジスタに対応している事を指定する" do
            set_load_data([
              [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error

            set_load_data([
              [nil, "register_0", "0x00", "[1]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error

            set_load_data([
              [nil, "register_0", "0x00", "[1, 1]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.to raise_register_map_error("multiple dimensions array register is not allowed", position("block_0", 4, 4))
          end
        end

        context "support_multiple_dimensions: falseが指定された場合" do
          before do
            define_item(:bar) { support_array_register support_multiple_dimensions: false }
          end

          it "対象レジスタが単一次元の配列レジスタに対応している事を指定する" do
            set_load_data([
              [nil, "register_0", "0x00", nil, "bar", "bit_field_0_0", "[0]", :rw, 0, nil]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error

            set_load_data([
              [nil, "register_0", "0x00", "[1]", "bar", "bit_field_0_0", "[0]", :rw, 0, nil]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error

            set_load_data([
              [nil, "register_0", "0x00", "[1, 1]", "bar", "bit_field_0_0", "[0]", :rw, 0, nil]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.to raise_register_map_error("multiple dimensions array register is not allowed", position("block_0", 4, 4))
          end
        end

        context "support_multiple_dimensions: trueが指定された場合" do
          before do
            define_item(:bar) { support_array_register support_multiple_dimensions: true }
          end

          it "対象レジスタが複数次元の配列レジスタに対応している事を指定する" do
            set_load_data([
              [nil, "register_0", "0x00"       , nil     , "bar", "bit_field_0_0", "[0]", :rw, 0, nil],
              [nil, "register_1", "0x04"       , "[1]"   , "bar", "bit_field_1_0", "[0]", :rw, 0, nil],
              [nil, "register_2", "0x08 - 0x0F", "[1, 2]", "bar", "bit_field_2_0", "[0]", :rw, 0, nil]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error
          end
        end
      end
    end

    describe "required_byte_size" do
      context "amount_of_registersが指定された場合" do
        before do
          define_item(:foo) do
            support_array_register support_multiple_dimensions: true
            required_byte_size amount_of_registers
          end
        end

        it "実装されたレジスタ分のバイトサイズが必要であることを指定する" do
          set_load_data([
            [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00", "[1]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00 - 0x07", "[2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00 - 0x07", "[1, 2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00 - 0x07", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(8) is not matched with required size(4)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00", "[2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(4) is not matched with required size(8)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00 - 0x0B", "[2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(12) is not matched with required size(8)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00", "[1, 2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(4) is not matched with required size(8)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00 - 0x0B", "[1, 2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(12) is not matched with required size(8)", position("block_0", 4, 4))
        end
      end

      context "data_widthが指定された場合" do
        before do
          define_item(:foo) do
            support_array_register support_multiple_dimensions: true
            required_byte_size data_width
          end
        end

        it "データ幅分のバイトサイズが必要であることを指定する" do
          set_load_data([
            [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00", "[1]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00", "[2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00", "[1, 2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00 - 0x07", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(8) is not matched with required size(4)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00 - 0x07", "[1]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(8) is not matched with required size(4)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00 - 0x07", "[2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(8) is not matched with required size(4)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00 - 0x07", "[1, 2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(8) is not matched with required size(4)", position("block_0", 4, 4))
        end
      end

      context "any_sizeが指定された場合" do
        before do
          define_item(:foo) do
            support_array_register support_multiple_dimensions: true
            required_byte_size any_size
          end
        end

        it "任意のバイトサイズで使用できることを指定する" do
          set_load_data([
            [nil, "register_0", "0x00"       , nil     , "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
            [nil, "register_1", "0x04 - 0x0B", nil     , "foo", "bit_field_1_0", "[0]", :rw, 0, nil],
            [nil, "register_2", "0x10"       , "[1]"   , "foo", "bit_field_2_0", "[0]", :rw, 0, nil],
            [nil, "register_3", "0x14 - 0x1B", "[1]"   , "foo", "bit_field_3_0", "[0]", :rw, 0, nil],
            [nil, "register_4", "0x20 - 0x27", "[2]"   , "foo", "bit_field_4_0", "[0]", :rw, 0, nil],
            [nil, "register_5", "0x28       ", "[2]"   , "foo", "bit_field_5_0", "[0]", :rw, 0, nil],
            [nil, "register_6", "0x2C - 0x37", "[2]"   , "foo", "bit_field_6_0", "[0]", :rw, 0, nil],
            [nil, "register_7", "0x40 - 0x47", "[1, 2]", "foo", "bit_field_7_0", "[0]", :rw, 0, nil],
            [nil, "register_8", "0x48       ", "[1, 2]", "foo", "bit_field_8_0", "[0]", :rw, 0, nil],
            [nil, "register_9", "0x4C - 0x57", "[1, 2]", "foo", "bit_field_9_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end
      end

      context "未指定の場合" do
        before do
          define_item(:foo) do
            support_array_register support_multiple_dimensions: true
          end
        end

        it "amount_of_registersを指定した場合が既定の動作" do
          set_load_data([
            [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00", "[1]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00 - 0x07", "[2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00 - 0x07", "[1, 2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error

          set_load_data([
            [nil, "register_0", "0x00 - 0x07", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(8) is not matched with required size(4)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00", "[2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(4) is not matched with required size(8)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00 - 0x0B", "[2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(12) is not matched with required size(8)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00", "[1, 2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(4) is not matched with required size(8)", position("block_0", 4, 4))

          set_load_data([
            [nil, "register_0", "0x00 - 0x0B", "[1, 2]", "foo", "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("byte size(12) is not matched with required size(8)", position("block_0", 4, 4))
        end
      end
    end

    describe ".need_no_bit_fields" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, "foo", "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, "bar", "bit_field_1_0", "[0]", :rw, 0, nil]
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
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", :rw, 0, nil],
        ]
      end

      it ":defaultを返す" do
        expect(registers[0].type).to eq :default
      end
    end

    describe "#readable?" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", :rw      , 0, nil],
          [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[0]", :ro      , 0, nil],
          [nil, "register_2", "0x08", nil, nil, "bit_field_2_0", "[1]", :ro      , 0, nil],
          [nil, nil         , nil   , nil, nil, "bit_field_2_1", "[0]", :wo      , 0, nil],
          [nil, "register_3", "0x0C", nil, nil, "bit_field_3_0", "[0]", :wo      , 0, nil],
          [nil, "register_4", "0x10", nil, nil, "bit_field_4_0", "[0]", :reserved, 0, nil]
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
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", :rw      , 0, nil],
          [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[0]", :wo      , 0, nil],
          [nil, "register_2", "0x08", nil, nil, "bit_field_2_0", "[1]", :wo      , 0, nil],
          [nil, nil         , nil   , nil, nil, "bit_field_2_1", "[0]", :ro      , 0, nil],
          [nil, "register_3", "0x0C", nil, nil, "bit_field_3_0", "[0]", :ro      , 0, nil],
          [nil, "register_4", "0x10", nil, nil, "bit_field_4_0", "[0]", :reserved, 0, nil]
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
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", :rw, 0, nil],
        ]
      end

      it "配下にビットフィールドを持つ" do
        expect(registers[0].bit_fields).not_to be_empty
      end
    end

    it "単一次元の配列レジスタに対応する" do
      set_load_data([
        [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", :rw, 0, nil]
      ])
      expect {
        @factory.create(configuration, register_map_file)
      }.not_to raise_error

      set_load_data([
        [nil, "register_0", "0x10 - 0x17", "[2]", nil, "bit_field_0_0", "[0]", :rw, 0, nil]
      ])
      expect {
        @factory.create(configuration, register_map_file)
      }.not_to raise_error

      set_load_data([
        [nil, "register_0", "0x00", "[1, 1]"  , nil, "bit_field_0_0", "[0]", :rw, 0, nil]
      ])
      expect {
        @factory.create(configuration, register_map_file)
      }.to raise_error RgGen::RegisterMapError
    end

    it "実装されているレジスタ分のバイトサイズを必要とする" do
      set_load_data([
        [nil, "register_0", "0x00 - 0x07", nil, nil, "bit_field_0_0", "[0]", :rw, 0, nil]
      ])
      expect {
        @factory.create(configuration, register_map_file)
      }.to raise_error RgGen::RegisterMapError

      set_load_data([
        [nil, "register_0", "0x00", "[2]", nil, "bit_field_0_0", "[0]", :rw, 0, nil]
      ])
      expect {
        @factory.create(configuration, register_map_file)
      }.to raise_error RgGen::RegisterMapError

      set_load_data([
        [nil, "register_0", "0x00 - 0x0B", "[2]", nil, "bit_field_0_0", "[0]", :rw, 0, nil]
      ])
      expect {
        @factory.create(configuration, register_map_file)
      }.to raise_error RgGen::RegisterMapError
    end
  end

  describe "factory" do
    context "入力が空セルの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil  , "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, ""   , "bit_field_1_0", "[0]", :rw, 0, nil]
        ]
      end

      it "デフォルトのレジスタを生成する" do
        expect(registers.map(&:type)).to all(eq :default)
      end
    end

    context "入力がdefaultの場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, :default , "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, "default", "bit_field_1_0", "[0]", :rw, 0, nil],
          [nil, "register_2", "0x08", nil, :DEFAULT , "bit_field_2_0", "[0]", :rw, 0, nil],
          [nil, "register_3", "0x0C", nil, "DEFAULT", "bit_field_3_0", "[0]", :rw, 0, nil]
        ]
      end

      it "デフォルトのレジスタを生成する" do
        expect(registers.map(&:type)).to all(eq :default)
      end
    end

    context "入力がenableで有効したレジスタ型の場合" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, :foo , "bit_field_0_0", "[0]", :rw, 0, nil],
          [nil, "register_1", "0x04", nil, "foo", "bit_field_1_0", "[0]", :rw, 0, nil],
          [nil, "register_2", "0x08", nil, :BAR , "bit_field_2_0", "[0]", :rw, 0, nil],
          [nil, "register_3", "0x0C", nil, "BAR", "bit_field_3_0", "[0]", :rw, 0, nil]
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
            [nil, "register_0", "0x00", nil, invalid_value, "bit_field_0_0", "[0]", :rw, 0, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("unknown register type: #{invalid_value}", position("block_0", 4, 4))
        end
      end
    end
  end
end
