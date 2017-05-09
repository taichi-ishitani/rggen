require_relative '../spec_helper'

describe 'bit_field/type' do
  include_context 'bit field type common'
  include_context 'configuration common'
  include_context 'rtl common'
  include_context 'ral common'

  before(:all) do
    items = {}
    [:foo, :BAR, :baz].each do |item_name|
      RgGen.list_item(:bit_field, :type, item_name) do
        register_map {items[item_name] = self}
        rtl {}
        ral do
          if item_name == :BAR
            access :rw
            model_name { :field_bar }
            hdl_path { "u_#{bit_field.name}.bar_value" }
          end
        end
      end
    end

    enable :global, [:data_width, :address_width]
    enable :register_block, [:name, :byte_size]
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, [:indirect]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :foo, :BAR]
    enable :register_block, [:clock_reset, :host_if]
    enable :register_block, :host_if, :apb

    @items    = items
    @factory  = build_register_map_factory
  end

  before(:all) do
    ConfigurationDummyLoader.load_data({})
    @configuration  = build_configuration_factory.create(configuration_file)
  end

  after(:all) do
    clear_enabled_items
    clear_dummy_list_items(:type, [:foo, :BAR, :baz])
  end

  after do
    @items.each_value do |item|
      [:@readable, :@writable, :@required_width, :@need_initial_value, :@use_reference, :@reference_options].each do |variable|
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

  describe "register_map" do
    describe "#type" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[3]", "BAR", nil, nil],
          [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[2]", "foo", nil, nil],
          [nil, nil         , nil   , nil, nil, "bit_field_0_2", "[1]", "fOo", nil, nil],
          [nil, nil         , nil   , nil, nil, "bit_field_0_3", "[0]", "BaR", nil, nil]
        ]
      end

      it "#enableで登録されたタイプ名を返す" do
        expect(bit_fields.map(&:type)).to match [:BAR, :foo, :foo, :BAR]
      end
    end

    describe ".read_write" do
      before do
        define_item(:foo) {read_write}
      end

      let(:load_data) do
        [[nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "foo", nil, nil]]
      end

      it "アクセス属性をread-writeに設定する" do
        expect(bit_fields[0]).to match_access(:read_write)
      end
    end

    describe ".read_only" do
      before do
        define_item(:foo) {read_only}
      end

      let(:load_data) do
        [[nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "foo", nil, nil]]
      end

      it "アクセス属性をread-onlyに設定する" do
        expect(bit_fields[0]).to match_access(:read_only)
      end
    end

    describe ".write_only" do
      before do
        define_item(:foo) {write_only}
      end

      let(:load_data) do
        [[nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "foo", nil, nil]]
      end

      it "アクセス属性をwrite-onlyに設定する" do
        expect(bit_fields[0]).to match_access(:write_only)
      end
    end

    describe ".reserved" do
      before do
        define_item(:foo) {reserved}
      end

      let(:load_data) do
        [[nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", "foo", nil, nil]]
      end

      it "アクセス属性をreservedに設定する" do
        expect(bit_fields[0]).to match_access(:reserved)
      end
    end

    describe ".required_width" do
      context ".required_widthで必要なビット幅が設定されていない場合" do
        it "任意の幅のビットフィールドで使用できる" do
          set_load_data([
            [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[15:8]", "foo", nil, nil],
            [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]"   , "foo", nil, nil],
            [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[31:0]", "foo", nil, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end
      end

      context "必要なビット幅が値で設定されている場合" do
        before do
          define_item(:foo) {required_width 2}
        end

        it "設定したビット幅を持つビットフィールドで使用できる" do
          set_load_data([
            [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[17:16]", "foo", nil, nil],
            [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[1:0]"  , "foo", nil, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end

        context "設定した幅以外のビットフィールドで使用した場合" do
          it "RegisterMapErrorを発生させる" do
            {1 => "[0]", 3 => "[2:0]", 32 => "[31:0]"}.each do |width, assignment|
              set_load_data([[nil, "register_0", "0x00", nil, nil, "bit_field_0_0", assignment, "foo", nil, nil]])
              expect {
                @factory.create(configuration, register_map_file)
              }.to raise_register_map_error("2 bit(s) width required: #{width} bit(s)", position("block_0", 4, 7))
            end
          end
        end
      end

      context "必要なビット幅が配列で複数指定されている場合" do
        before do
          define_item(:foo) {required_width [1, 3]}
        end

        it "指定した幅のどれかを持つビットフィールドで使用できる" do
          set_load_data([
            [nil, "register_0", "0x00", nil, nil, "bit_field0_0", "[6:4]", "foo", nil, nil],
            [nil, nil         , nil   , nil, nil, "bit_field0_1", "[0]"  , "foo", nil, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end

        context "指定された以外の幅を持つビットフィールドで使用した場合" do
          it "RgGen::RegisterMapErrorを発生させる" do
            {2 => "[1:0]", 4 => "[3:0]"}.each do |width, assignment|
              set_load_data([[nil, "register_0", "0x00", nil, nil, "bit_field_0_0", assignment, "foo", nil, nil]])
              expect {
                @factory.create(configuration, register_map_file)
              }.to raise_register_map_error("#{[1, 3]} bit(s) width required: #{width} bit(s)", position("block_0", 4, 7))
            end
          end
        end
      end

      context "必要なビット幅が範囲で指定されている場合" do
        before do
          define_item(:foo) {required_width 2..4}
        end

        it "指定した幅のどれかを持つビットフィールドで使用できる" do
          set_load_data([
            [nil, "register_0", "0x00", nil, nil, "bit_field0_0", "[11:8]", "foo", nil, nil],
            [nil, nil         , nil   , nil, nil, "bit_field0_1", "[6:4]" , "foo", nil, nil],
            [nil, nil         , nil   , nil, nil, "bit_field0_2", "[1:0]" , "foo", nil, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end

        context "指定された以外の幅を持つビットフィールドで使用した場合" do
          it "RgGen::RegisterMapErrorを発生させる" do
            {1 => "[0]", 5 => "[4:0]"}.each do |width, assignment|
              set_load_data([[nil, "register_0", "0x00", nil, nil, "bit_field_0_0", assignment, "foo", nil, nil]])
              expect {
                @factory.create(configuration, register_map_file)
              }.to raise_register_map_error("#{2..4} bit(s) width required: #{width} bit(s)", position("block_0", 4, 7))
            end
          end
        end
      end

      context "必要なビット幅が:full_widthで設定されている場合" do
        before do
          define_item(:foo) {required_width full_width}
        end

        it "コンフィグレーションで指定したデータ幅を持つビットフィールドで使用できる" do
          set_load_data([
            [nil, "register_0", "0x00", nil, nil, "bit_field0_0", "[31:0]", "foo", nil, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end

        context "データ幅以外のビットフィールド使用した場合" do
          it "RgGen::RegisterMapErrorを発生させる" do
            {1 => "[0]", 31 => "[30:0]"}.each do |width, assignment|
              set_load_data([[nil, "register_0", "0x00", nil, nil, "bit_field_0_0", assignment, "foo", nil, nil]])
              expect {
                @factory.create(configuration, register_map_file)
              }.to raise_register_map_error("#{configuration.data_width} bit(s) width required: #{width} bit(s)", position("block_0", 4, 7))
            end
          end
        end
      end
    end

    describe ".need_initial_value" do
      context ".need_initial_valueで初期値の有無の指定がない場合" do
        it "初期値の有無に関わらず使用できる" do
          set_load_data([
            [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[15:8]", "foo", nil, nil],
            [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]"   , "foo", 1  , nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end
      end

      context ".need_initial_valueで初期値ありに指定された場合" do
        before do
          define_item(:foo) {need_initial_value}
        end

        it "初期値を持つビットフィールドで使用できる" do
          set_load_data([
            [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[15:8]", "foo", 0, nil],
            [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]"   , "foo", 1, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end

        context "初期値を持たないビットフィールドで使用した場合" do
          it "RgGen::RegisterMapErrorを発生させる" do
            set_load_data([
            [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[15:8]", "foo", nil, nil]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_error "no initial value", position("block_0", 4, 7)
          end
        end
      end
    end

    describe ".use_reference" do
      context ".use_referenceで参照信号設定がない場合" do
        it "参照ビットフィールドの指定に有無にかかわらず使用できる" do
          set_load_data([
            [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[15:8]", "foo", nil, nil            ],
            [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]"   , "foo", nil, nil            ],
            [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[31:0]", "foo", nil, "bit_field_0_0"]
          ])
          expect {
            @factory.create(configuration, register_map_file)
          }.not_to raise_error
        end
      end

      describe "requiredオプション" do
        context "オプションの指定がない場合" do
          before do
            define_item(:foo) {use_reference}
          end

          it "参照ビットフィールドの指定に有無にかかわらず使用できる" do
            set_load_data([
              [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[1]", "foo", nil, nil            ],
              [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]", "foo", nil, "bit_field_0_0"]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error
          end
        end

        context "falseに設定されている場合" do
          before do
            define_item(:foo) {use_reference required:false}
          end

          it "参照ビットフィールドの指定に有無にかかわらず使用できる" do
            set_load_data([
              [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[2]"  , "foo", nil, nil            ],
              [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[1:0]", "foo", nil, "bit_field_0_0"]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error
          end
        end

        context "trueに設定されている場合" do
          before do
            define_item(:foo) {use_reference required:true}
          end

          it "参照ビットフィールドを持つビットフィールドで使用できる" do
            set_load_data([
              [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[4]"  , "BAR", nil, nil            ],
              [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[3:0]", "foo", nil, "bit_field_0_0"]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error
          end

          context "参照信号を持たないビットフィールで使用した場合" do
            it "RgGen::RegisterMapErrorを発生させる" do
              set_load_data([
                [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[7:4]", "foo", nil, nil]
              ])
              expect {
                @factory.create(configuration, register_map_file)
              }.to raise_error "reference bit field required", position("block_0", 4, 7)
            end
          end
        end
      end

      describe "widthオプション" do
        context "参照ビットフィールド幅の指定がない場合" do
          before do
            define_item(:foo) {use_reference}
          end

          it "1ビットの参照ビットフィールドを持つビットフィールで使用できる" do
            set_load_data([
              [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[1]", "BAR", nil, nil            ],
              [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]", "foo", nil, "bit_field_0_0"]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error
          end

          context "2ビット以上のビットフィールドを参照ビットフィールドに指定した場合" do
            it "RgGen::RegisterMapErrorを発生させる" do
              set_load_data([
                [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[2:1]", "BAR", nil, nil            ],
                [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]"  , "foo", nil, "bit_field_0_0"]
              ])
              expect {
                @factory.create(configuration, register_map_file)
              }.to raise_error "1 bit(s) reference bit field required: 2", position("block_0", 4, 7)
            end
          end
        end

        context "参照ビットフィールド幅が数字で指定された場合" do
          before do
            define_item(:foo) {use_reference width:2}
          end

          it "指定幅の参照ビットフィールドを持つビットフィールで使用できる" do
            set_load_data([
              [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[5:4]", "BAR", nil, nil            ],
              [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[3:0]", "foo", nil, "bit_field_0_0"]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error
          end

          context "指定幅以外のビットフィールドを参照ビットフィールドに指定した場合" do
            it "RgGen::RegisterMapErrorを発生させる" do
              {3 => "[6:4]", 1 => "[4]"}.each do |width, assigment|
                set_load_data([
                  [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", assigment, "BAR", nil, nil            ],
                  [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]"    , "foo", nil, "bit_field_0_0"]
                ])
                expect {
                  @factory.create(configuration, register_map_file)
                }.to raise_error "2 bit(s) reference bit field required: #{width}", position("block_0", 4, 7)
              end
            end
          end
        end

        context "参照ビットフィールド幅が:same_widthで指定された場合" do
          before do
            define_item(:foo) {use_reference width:same_width}
          end

          it "同じ幅の参照ビットフィールドを持つビットフィールで使用できる" do
            set_load_data([
              [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[7:4]", "BAR", nil, nil            ],
              [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[3:0]", "foo", nil, "bit_field_0_0"]
            ])
            expect {
              @factory.create(configuration, register_map_file)
            }.not_to raise_error
          end

          context "違う幅のビットフィールドを参照ビットフィールドに指定した場合" do
            it "RgGen::RegisterMapErrorを発生させる" do
              {3 => "[6:4]", 1 => "[4]"}.each do |width, assigment|
                set_load_data([
                  [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", assigment, "BAR", nil, nil            ],
                  [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[1:0]"  , "foo", nil, "bit_field_0_0"]
                ])
                expect {
                  @factory.create(configuration, register_map_file)
                }.to raise_error "2 bit(s) reference bit field required: #{width}", position("block_0", 4, 7)
              end
            end
          end
        end
      end
    end

    context "Rgen.enableで有効にされたタイプ以外が入力された場合" do
      it "RegisterMapErrorを発生させる" do
        ["baz", "qux"].each do |type|
          set_load_data([[nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[0]", type, nil, nil]])
          expect {
            @factory.create(configuration, register_map_file)
          }.to raise_register_map_error("unknown bit field type: #{type}", position("block_0", 4, 7))
        end
      end
    end

    describe "#irq?" do
      let(:load_data) do
        [
          [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[8]", "foo", nil, nil],
          [nil, nil         , nil   , nil, nil, "bit_field_0_1", "[0]", "foo", nil, nil]
        ]
      end

      context "通常の場合" do
        it "割り込み要求ではないことを示す" do
          expect(bit_fields[0]).not_to be_irq
          expect(bit_fields[1]).not_to be_irq
        end
      end

      context ".irq?で#irq?が再定義された場合" do
        before do
          define_item(:foo) do
            irq? { bit_field.name == "bit_field_0_0" }
          end
        end

        it ".irq?に与えたブロックの評価結果を返す" do
          expect(bit_fields[0]).to be_irq
          expect(bit_fields[1]).not_to be_irq
        end
      end
    end
  end

  describe "rtl" do
    let(:register_map) do
      set_load_data([
        [nil, "register_0", "0x00"     , nil     , nil                                     , "bit_field_0_0", "[31:0]" , "foo", nil, nil],
        [nil, "register_1", "0x04-0x0B", "[2]"   , nil                                     , "bit_field_1_0", "[0]"    , "foo", nil, nil],
        [nil, "register_2", "0x0C"     , "[3, 4]", "indirect: bit_field_3_0, bit_field_3_1", "bit_field_2_0", "[0]"    , "foo", nil, nil],
        [nil, "register_3", "0x10"     , nil     , nil                                     , "bit_field_3_0", "[31:16]", "ro" , nil, nil],
        [nil, nil         , nil        , nil     , nil                                     , "bit_field_3_1", "[15:0]" , "ro" , nil, nil]
      ])
      @factory.create(configuration, register_map_file)
    end

    let(:rtl) do
      build_rtl_factory.create(@configuration, register_map).bit_fields
    end

    describe "#value" do
      it "自身がアサインされているregister_ifのvalue信号を返す" do
        expect(rtl[0].value).to match_identifier 'register_if[0].value[31:0]'
        expect(rtl[1].value).to match_identifier 'register_if[1+g_i].value[0]'
        expect(rtl[2].value).to match_identifier 'register_if[3+4*g_i+g_j].value[0]'
        expect(rtl[3].value).to match_identifier 'register_if[15].value[31:16]'
        expect(rtl[4].value).to match_identifier 'register_if[15].value[15:0]'
      end
    end

    describe "#bit_field_if" do
      it "自身が接続されるbit_field_ifの識別子を返す" do
        expect(rtl[0].bit_field_if).to match_identifier 'register_0_bit_field_if[0]'
        expect(rtl[1].bit_field_if).to match_identifier 'register_1_bit_field_if[g_i][0]'
        expect(rtl[2].bit_field_if).to match_identifier 'register_2_bit_field_if[g_i][g_j][0]'
        expect(rtl[3].bit_field_if).to match_identifier 'register_3_bit_field_if[0]'
        expect(rtl[4].bit_field_if).to match_identifier 'register_3_bit_field_if[1]'
      end
    end
  end

  describe "ral" do
    let(:register_map) do
      set_load_data([
        [nil, "register_0", "0x00", nil, nil, "bit_field_0_0", "[31:0]", "rw" , 0  , nil],
        [nil, "register_1", "0x04", nil, nil, "bit_field_1_0", "[31:0]", "foo", nil, nil],
        [nil, "register_2", "0x08", nil, nil, "bit_field_2_0", "[31:0]", "BAR", nil, nil]
      ])
      @factory.create(configuration, register_map_file)
    end

    let(:ral) do
      build_ral_factory.create(@configuration, register_map).bit_fields
    end

    describe "#access" do
      context ".accessでモデルのアクセス権設定されていない場合" do
        it "大文字化したタイプ名を返す" do
          expect(ral[0].access).to eq '"RW"'
          expect(ral[1].access).to eq '"FOO"'
        end
      end

      context ".accessでモデルのアクセス権設定された場合" do
        it "設定したアクセス権を大文字に化して返す" do
          expect(ral[2].access).to eq '"RW"'
        end
      end
    end

    describe "#model_name" do
      context "通常の場合" do
        it "デフォルトのモデル名を返す" do
          expect(ral[0].model_name).to eq :rggen_ral_field
          expect(ral[1].model_name).to eq :rggen_ral_field
        end
      end

      context ".model_nameでモデル名の設定がされた場合" do
        it ".model_nameで設定されたモデル名を返す" do
          expect(ral[2].model_name).to eq :field_bar
        end
      end
    end

    describe "#hdl_path" do
      context "通常の場合" do
        it "デフォルトの階層パスを返す" do
          expect(ral[0].hdl_path).to eq "u_bit_field_0_0.value"
          expect(ral[1].hdl_path).to eq "u_bit_field_1_0.value"
        end
      end

      context ".hdl_pathで階層パスの設定がされた場合" do
        it ".hdl_pathで設定された階層パスを返す" do
          expect(ral[2].hdl_path).to eq "u_bit_field_2_0.bar_value"
        end
      end
    end
  end
end
