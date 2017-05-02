require_relative '../../spec_helper'

describe 'register/types/external' do
  include_context 'register common'
  include_context 'configuration common'

  before(:all) do
    enable :global, [:data_width, :address_width]
    ConfigurationDummyLoader.load_data({})
    @configuration  = build_configuration_factory.create(configuration_file)
  end

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, :external
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :wo, :reserved]
    enable :register_block, [:clock_reset, :bus_splitter]
    @factory  = build_register_map_factory
  end

  after(:all) do
    clear_enabled_items
  end

  let(:configuration) do
    @configuration
  end

  let(:register_map) do
    set_load_data([
      [nil, "register_0", "0x00 - 0x7F", nil, :external, "bit_field_0_0", "[0]", :rw, 0, nil]
    ])
    @factory.create(configuration, register_map_file)
  end

  let(:external_register) do
    register_map.registers[0]
  end

  describe "register_map" do
    it "型名は:external" do
      expect(external_register.type).to eq :external
    end

    it "読み書き可能レジスタ" do
      expect(external_register).to be_readable
      expect(external_register).to be_writable
      expect(external_register).not_to be_read_only
      expect(external_register).not_to be_write_only
      expect(external_register).not_to be_reserved
    end

    it "配列レジスタに対応しない" do
      set_load_data([
        [nil, "register_0", "0x00", "[1]", :external, "bit_field_0_0", "[0]", :rw, 0, nil]
      ])
      expect {
        @factory.create(configuration, register_map_file)
      }.to raise_error RgGen::RegisterMapError

      set_load_data([
        [nil, "register_0", "0x00", "[1, 1]", :external, "bit_field_0_0", "[0]", :rw, 0, nil]
      ])
      expect {
        @factory.create(configuration, register_map_file)
      }.to raise_error RgGen::RegisterMapError
    end

    it "任意のバイト幅で使用できる" do
      set_load_data([
        [nil, "register_0", "0x00"       , nil, :external, "bit_field_0_0", "[0]", :rw, 0, nil],
        [nil, "register_1", "0x04 - 0x0B", nil, :external, "bit_field_1_0", "[0]", :rw, 0, nil]
      ])
      expect {
        @factory.create(configuration, register_map_file)
      }.not_to raise_error
    end

    it "配下にビットフィールドを持たない" do
      expect(external_register.bit_fields).to be_empty
    end
  end

  describe "rtl" do
    include_context "rtl common"

    before(:all) do
      @rtl_factory  = build_rtl_factory
    end

    let(:rtl) do
      @rtl_factory.create(configuration, register_map).registers[0]
    end

    it "rggen_bus_ifをポートとして持つ" do
      expect(rtl).to have_interface_port(:bus_if, name: "register_0_bus_if", type: :rggen_bus_if, modport: :master)
    end

    describe "#generate_code" do
      let(:expected_code) do
        <<'CODE'
rggen_external_register #(
  .ADDRESS_WIDTH  (8),
  .START_ADDRESS  (8'h00),
  .END_ADDRESS    (8'h7f),
  .DATA_WIDTH     (32)
) u_register_0 (
  .clk                  (clk),
  .rst_n                (rst_n),
  .register_control_if  (register_if[0]),
  .register_data_if     (register_if[0]),
  .bus_if               (register_0_bus_if)
);
CODE
      end

      it "外部レジスタモジュールをインスタンスするコードを生成する" do
        expect(rtl).to generate_code(:module_item, :top_down, expected_code)
      end
    end
  end

  describe "c_header" do
    include_context 'c header common'

    before(:all) do
      @c_header_factory = build_c_header_factory
    end

    let(:c_header) do
      @c_header_factory.create(configuration, register_map).registers[0]
    end

    describe "#address_struct_member" do
      it "外部レジスタ用のアドレス構造体のメンバー定義を返す" do
        expect(c_header.address_struct_member).to match_string "RGGEN_EXTERNAL_REGISTERS(128, REGISTER_0) register_0"
      end
    end
  end
end
