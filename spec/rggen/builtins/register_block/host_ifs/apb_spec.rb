require_relative '../../spec_helper'

describe "register_block/apb" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, :address_width
    enable :global, :data_width
    enable :register_block, :name
    enable :register_block, :byte_size
    enable :register_block, :clock_reset
    enable :register_block, :host_if
    enable :register_block, :host_if, [:apb]
  end

  after(:all) do
    clear_enabled_items
  end

  describe 'configuration' do
    before(:all) do
      @factory  = build_configuration_factory
    end

    let(:factory) do
      @factory
    end

    def configuration(load_data = {})
      ConfigurationDummyLoader.load_data(load_data)
      @factory.create(configuration_file)
    end

    it "apb選択時、アドレス幅は32ビット以下で使用できる" do
      expect {
        configuration(host_if: :apb, address_width: 8)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, address_width: 16)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, address_width: 32)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, address_width: 33)
      }.to raise_configuration_error 'apb supports 32 or less bits address width only: 33'
      expect {
        configuration(host_if: :apb, address_width: 64)
      }.to raise_configuration_error 'apb supports 32 or less bits address width only: 64'
    end

    it "apb選択時、データ幅は32ビット以下で使用できる" do
      expect {
        configuration(host_if: :apb, data_width: 8)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, data_width: 16)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, data_width: 32)
      }.not_to raise_error
      expect {
        configuration(host_if: :apb, data_width: 64)
      }.to raise_configuration_error 'apb supports 32 or less bits data width only: 64'
      expect {
        configuration(host_if: :apb, data_width: 128)
      }.to raise_configuration_error 'apb supports 32 or less bits data width only: 128'
    end
  end

  describe 'rtl' do
    before(:all) do
      configuration = create_configuration(host_if: :apb, data_width: 32, address_width: 16)
      register_map  = create_register_map(
        configuration,
        "block_0" => [
          [nil, nil, "block_0"],
          [nil, nil, 256      ]
        ]
      )
      @rtl  = build_rtl_factory.create(configuration, register_map).register_blocks[0]
    end

    let(:rtl) do
      @rtl
    end

    let(:data_width) do
      32
    end

    let(:host_address_width) do
      16
    end

    it "rggen_apb_ifを入出力ポートに持つ" do
      expect(rtl).to have_interface_port(:apb_if, type: :rggen_apb_if, modport: :slave)
    end

    describe "#generate_code" do
      let(:expected_code) do
        <<'CODE'
rggen_host_if_apb #(
  .LOCAL_ADDRESS_WIDTH  (8)
) u_host_if (
  .apb_if (apb_if),
  .bus_if (bus_if)
);
CODE
      end

      it "APB用のホストIFモジュールをインスタンスするコードを出力する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end
  end
end
