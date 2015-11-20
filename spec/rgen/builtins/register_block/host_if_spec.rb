require_relative '../spec_helper'

describe "register_block/host_if" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    [:Foo, :bar, :baz].each do |host_if|
      RGen.list_item(:register_block, :host_if, host_if) do
        rtl {}
      end
    end

    RGen.enable(:register_block, :host_if)
    RGen.enable(:register_block, :host_if, [:bar, :Foo, :qux])

    @configuration_factory  = build_configuration_factory
  end

  after(:all) do
    clear_enabled_items
    clear_dummy_list_items(:host_if, [:Foo, :bar, :baz])
  end

  describe "configuration" do
    def configuration(value = nil)
      load_data           = {}
      load_data[:host_if] = value if value
      ConfigurationDummyLoader.load_data(load_data)
      @configuration_factory.create(configuration_file)
    end

    describe "#host_if" do
      context "ロード結果のHashに:host_ifが含まれないとき" do
        it "デフォルト値として、有効にされた一番初めのホストIFを返す" do
          expect(configuration.host_if).to eq :bar
        end
      end

      context "ロード結果のHashに:host_ifが含まれていて、有効にされたホストIFに含まれる場合" do
        it "登録されている表記でホストIF名を返す" do
          {:Foo => :Foo, :foo => :Foo, "bar" => :bar, "BAR" => :bar}.each do |value, host_if_name|
            expect(configuration(value).host_if).to eq host_if_name
          end
        end
      end

      context "ロード結果のHashに:host_ifが含まれていて、有効にされたホストIFに含まれない場合" do
        it "RGen::ConfigurationErrorを発生させる" do
          [:baz, :BAZ, "qux", "QUX"].each do |value|
            expect {
              configuration(value)
            }.to raise_configuration_error "unknown host interface: #{value}"
          end
        end
      end
    end
  end
end
