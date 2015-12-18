require_relative '../spec_helper'

describe "register_block/host_if" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    [:Foo, :bar, :baz].each do |host_if|
      RGen.list_item(:register_block, :host_if, host_if) do
        rtl {
          define_method(:test) {host_if}
        }
      end
    end

    RGen.enable(:global, :address_width)
    RGen.enable(:global, :data_width   )
    RGen.enable(:register_block, :name     )
    RGen.enable(:register_block, :byte_size)
    RGen.enable(:register_block, :host_if  )
    RGen.enable(:register_block, :host_if, [:bar, :Foo, :qux])

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

      context "ロード結果のHashに:host_ifが含まれていて、有効にされたホストIFに含まれない場合" do
        it "RGen::ConfigurationErrorを発生させる" do
          [:baz, :BAZ, "qux", "QUX"].each do |value|
            expect {
              configuration(host_if: value)
            }.to raise_configuration_error "unknown host interface: #{value}"
          end
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
          [nil, nil, "block_0"],
          [nil, nil, 252      ]
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

    specify "configurationで指定したホストIFが生成される" do
      [:Foo, :bar].each do |host_if|
        expect(rtl(host_if: host_if).items[0].test).to eq host_if
      end
    end

    it "ホストIF用の信号群を持つ" do
      host_if_rtl = rtl(host_if: :foo, data_width: data_width)
      expect(host_if_rtl).to have_logic(:host_if, :command_valid , width: 1            )
      expect(host_if_rtl).to have_logic(:host_if, :write         , width: 1            )
      expect(host_if_rtl).to have_logic(:host_if, :read          , width: 1            )
      expect(host_if_rtl).to have_logic(:host_if, :address       , width: address_width)
      expect(host_if_rtl).to have_logic(:host_if, :write_data    , width: data_width   )
      expect(host_if_rtl).to have_logic(:host_if, :write_mask    , width: data_width   )
      expect(host_if_rtl).to have_logic(:host_if, :response_ready, width: 1            )
      expect(host_if_rtl).to have_logic(:host_if, :read_data     , width: data_width   )
      expect(host_if_rtl).to have_logic(:host_if, :status        , width: 2            )
    end
  end
end
