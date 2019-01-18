require_relative '../../spec_helper'

describe 'register/types/external' do
  include_context 'register common'
  include_context 'configuration common'

  before(:all) do
    enable :register_block, [:name, :byte_size]
    enable :register, [:name, :offset_address, :array, :type]
    enable :register, :type, :external
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value, :reference]
    enable :bit_field, :type, [:rw, :ro, :wo, :reserved]
    enable :register_block, [:clock_reset, :host_if]
    enable :register_block, :host_if, :apb
    enable :register, :rtl_top
    @factory  = build_register_map_factory
  end

  before(:all) do
    enable :global, [:data_width, :address_width, :unfold_sv_interface_port]
  end

  after(:all) do
    clear_enabled_items
  end

  let(:register_map) do
    set_load_data([
      [nil, "register_0", "0x00 - 0x7F", nil, :external, "bit_field_0_0", "[0]", :rw, 0, nil]
    ])
    @factory.create(configuration, register_map_file)
  end

  describe "register_map" do
    let(:configuration) do
      ConfigurationDummyLoader.load_data({})
      build_configuration_factory.create(configuration_file)
    end

    let(:external_register) do
      register_map.registers[0]
    end

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

    let(:address_width) { 32 }

    let(:data_width) { 32 }

    let(:external_address_width) { Math.clog2(0x7f - 0x00 + 1) }

    let(:configuration) do
      ConfigurationDummyLoader.load_data({data_width: data_width, address_width: address_width, unfold_sv_interface_port: unfold_sv_interface_port})
      build_configuration_factory.create(configuration_file)
    end

    let(:rtl) do
      @rtl_factory.create(configuration, register_map).registers[0]
    end

    context "unfold_sv_interface_portにfalseが設定されている場合" do
      let(:unfold_sv_interface_port) { [false, nil, 'false', 'nil', 'off', 'no'].shuffle.first }

      it "rggen_bus_ifをポートとして持つ" do
        expect(rtl).to have_interface_port(:register_block, :bus_if, name: "register_0_bus_if", type: :rggen_bus_if, modport: :master)
      end

      it "外部レジスタモジュールをインスタンスするコードを生成する" do
        expected_code = <<'CODE'
rggen_external_register #(
  .ADDRESS_WIDTH  (8),
  .START_ADDRESS  (8'h00),
  .END_ADDRESS    (8'h7f),
  .DATA_WIDTH     (32)
) u_register (
  .clk          (clk),
  .rst_n        (rst_n),
  .register_if  (register_if[0]),
  .bus_if       (register_0_bus_if)
);
CODE
        expect(rtl).to generate_code(:register, :top_down, expected_code)
      end
    end

    context "unfold_sv_interface_portにtrueが設定されている場合" do
      let(:unfold_sv_interface_port) { [true, 'true', 'on', 'yes'].shuffle.first }

      it "外部出力バス用の入出力ポートを持つ" do
        expect(rtl).to have_output(:register_block, :request, name: 'o_register_0_request', data_type: :logic, width: 1)
        expect(rtl).to have_output(:register_block, :address, name: 'o_register_0_address', data_type: :logic, width: external_address_width)
        expect(rtl).to have_output(:register_block, :direction, name: 'o_register_0_direction', data_type: :logic, width: 1)
        expect(rtl).to have_output(:register_block, :write_data, name: 'o_register_0_write_data', data_type: :logic, width: data_width)
        expect(rtl).to have_output(:register_block, :strobe, name: 'o_register_0_strobe', data_type: :logic, width: data_width / 8)
        expect(rtl).to have_input(:register_block, :done, name: 'i_register_0_done', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :write_done, name: 'i_register_0_write_done', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :read_done, name: 'i_register_0_read_done', data_type: :logic, width: 1)
        expect(rtl).to have_input(:register_block, :read_data, name: 'i_register_0_read_data', data_type: :logic, width: data_width)
        expect(rtl).to have_input(:register_block, :status, name: 'i_register_0_status', data_type: :logic, width: 2)
      end

      it "rggen_bus_ifのインスタンスを持つ" do
        expect(rtl).to have_interface(:register, :bus_if, type: :rggen_bus_if, name: 'bus_if', parameters: [external_address_width, data_width])
      end

      it "外部レジスタモジュールをインスタンスするコード(IF接続含む)を生成する" do
        expected_code = <<'CODE'
assign o_register_0_request = bus_if.request;
assign o_register_0_address = bus_if.address;
assign o_register_0_direction = bus_if.direction;
assign o_register_0_write_data = bus_if.write_data;
assign o_register_0_strobe = bus_if.write_strobe;
assign bus_if.done = i_register_0_done;
assign bus_if.write_done = i_register_0_write_done;
assign bus_if.read_done = i_register_0_read_done;
assign bus_if.read_data = i_register_0_read_data;
assign bus_if.status = rggen_rtl_pkg::rggen_status'(i_register_0_status);
rggen_external_register #(
  .ADDRESS_WIDTH  (8),
  .START_ADDRESS  (8'h00),
  .END_ADDRESS    (8'h7f),
  .DATA_WIDTH     (32)
) u_register (
  .clk          (clk),
  .rst_n        (rst_n),
  .register_if  (register_if[0]),
  .bus_if       (bus_if)
);
CODE
        expect(rtl).to generate_code(:register, :top_down, expected_code)
      end
    end
  end

  describe "c_header" do
    include_context 'c header common'

    before(:all) do
      @c_header_factory = build_c_header_factory
    end

    let(:configuration) do
      ConfigurationDummyLoader.load_data({})
      build_configuration_factory.create(configuration_file)
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
