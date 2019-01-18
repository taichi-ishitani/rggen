require_relative '../spec_helper'

describe "register_block/host_if" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    [:Foo, :bar, :baz].each do |host_if|
      RgGen.list_item(:register_block, :host_if, host_if) do
        configuration {} if host_if == :Foo

        rtl {
          define_method(:get_host_type) { host_if }
        }
      end
    end

    enable :global, [:address_width, :data_width, :unfold_sv_interface_port]
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:host_if, :clock_reset]
    enable :register_block, :host_if, [:bar, :Foo, :qux]
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, [:indirect, :external]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, :rw

    @configuration_factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
    clear_dummy_list_items(:host_if, [:Foo, :bar, :baz])
  end

  def configuration(load_data = {})
    ConfigurationDummyLoader.load_data(load_data)
    @configuration_factory.create(configuration_file)
  end

  describe "configuration" do
    describe "#host_if" do
      context "ロード結果のHashに:host_ifが含まれないとき" do
        it "デフォルト値として、有効にされた一番初めのホストIFを返す" do
          expect(configuration.host_if).to eq :bar
        end
      end

      context "ロード結果のHashに:host_ifが含まれていて、有効にされたホストIFに含まれる場合" do
        it "登録されている表記でホストIF名を返す" do
          {:Foo => :Foo, :foo => :Foo, "bar" => :bar, "BAR" => :bar}.each do |value, host_if_name|
            expect(configuration(host_if: value).host_if).to eq host_if_name
          end
        end
      end
    end

    it "アイテムクラスの定義の有無に関わらず、使用できる" do
      expect {
        configuration(host_if: :Foo)
      }.not_to raise_error
      expect {
        configuration(host_if: :bar)
      }.not_to raise_error
    end

    context "ロード結果のHashに:host_ifが含まれていて、有効にされたホストIFに含まれない場合" do
      it "RgGen::ConfigurationErrorを発生させる" do
        [:baz, :BAZ, "qux", "QUX"].each do |value|
          expect {
            configuration(host_if: value)
          }.to raise_configuration_error "unknown host interface: #{value}"
        end
      end
    end
  end

  describe "rtl" do
    before(:all) do
      @rtl_factory  = build_rtl_factory
      @register_map = create_register_map(
        configuration,
        "block_0" => [
          [nil, nil         , "block_0"                                                                                                 ],
          [nil, nil         , 252                                                                                                       ],
          [                                                                                                                             ],
          [                                                                                                                             ],
          [nil, "register_0", "0x00"     , nil    , nil                                     , "bit_field_0_0", "[0]"    , "rw", 0  , nil],
          [nil, nil         , nil        , nil    , nil                                     , "bit_field_0_1", "[31:16]", "rw", 0  , nil],
          [nil, "register_1", "0x04"     , nil    , nil                                     , "bit_field_1_0", "[31:0]" , "rw", 0  , nil],
          [nil, "register_2", "0x08-0x0F", "[2]"  , nil                                     , "bit_field_2_0", "[31:0]" , "rw", 0  , nil],
          [nil, "register_3", "0x10"     , "[2,4]", "indirect: bit_field_0_0, bit_field_0_1", "bit_field_3_0", "[31:0]" , "rw", 0  , nil],
          [nil, "register_4", "0x14"     , nil    , :external                               , nil            , nil      , nil , nil, nil],
          [nil, "register_5", "0x18"     , nil    , :external                               , nil            , nil      , nil , nil, nil]
        ]
      )
    end

    def rtl(load_data)
      @rtl_factory.create(configuration(load_data), @register_map).register_blocks[0]
    end

    let(:data_width) do
      16
    end

    let(:address_width) do
      8
    end

    let(:total_registers) do
      14
    end

    specify "configurationで指定したホストIFが生成される" do
      [:Foo, :bar].each do |host_if|
        expect(rtl(host_if: host_if).items[0].get_host_type).to eq host_if
      end
    end

    it "rggen_bus_if のインスタンスを持つ" do
      host_if_rtl = rtl(host_if: :foo, data_width: data_width)
      expect(host_if_rtl).to have_interface(
        :register_block, :register_if, type: :rggen_register_if, parameters: [address_width, data_width], dimensions: [total_registers]
      )
    end
  end
end
