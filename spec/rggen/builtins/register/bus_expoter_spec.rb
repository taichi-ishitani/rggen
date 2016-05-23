require_relative '../spec_helper'

describe "register/bus_exporter" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable :global, :data_width
    enable :global, :address_width
    enable :register_block, [:name, :byte_size]
    enable :register_block, [:clock_reset, :host_if, :response_mux]
    enable :register_block, :host_if, :apb
    enable :register, [:name, :offset_address, :array, :shadow, :external, :accessibility, :bus_exporter]
    enable :bit_field, [:name, :bit_assignment, :type, :initial_value]
    enable :bit_field, :type, :rw

    configuration = create_configuration
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil          , "block_0"                                                     ],
        [nil, nil          , 256                                                           ],
        [nil, nil          , nil                                                           ],
        [nil, nil          , nil                                                           ],
        [nil, "register_0" , "0x00"     , nil, nil, nil , "bit_field_0", "[31:0]", :rw, 0  ],
        [nil, "register_1" , "0x04"     , nil, nil, true, nil          , nil     , nil, nil],
        [nil, "register_2" , "0x08-0x0F", nil, nil, true, nil          , nil     , nil, nil],
        [nil, "register_3" , "0x10-0x1B", nil, nil, true, nil          , nil     , nil, nil]
      ]
    )
    @rtl  = build_rtl_factory.create(configuration, register_map).registers
  end

  after(:all) do
    clear_enabled_items
  end

  context "レジスタが内部レジスタの場合" do
    let(:rtl) do
      @rtl[0]
    end

    it "有効なアイテムではない" do
      expect(rtl).not_to have_item :register, :rtl, :bus_exporter
    end
  end

  context "レジスタが外部レジスタの場合" do
    let(:rtl) do
      @rtl[1..3]
    end

    it "有効なアイテムである" do
      expect(rtl).to all(have_item :register, :rtl, :bus_exporter)
    end

    it "外部バス用のポートを持つ" do
      expect(rtl[0]).to have_output(:valid     , name: "o_register_1_valid"     , width: 1)
      expect(rtl[0]).to have_output(:write     , name: "o_register_1_write"     , width: 1)
      expect(rtl[0]).to have_output(:read      , name: "o_register_1_read"      , width: 1)
      expect(rtl[0]).to have_output(:address   , name: "o_register_1_address"   , width: 2)
      expect(rtl[0]).to have_output(:strobe    , name: "o_register_1_strobe"    , width: 4)
      expect(rtl[0]).to have_output(:write_data, name: "o_register_1_write_data", width: 32)
      expect(rtl[0]).to  have_input(:ready     , name: "i_register_1_ready"     , width: 1)
      expect(rtl[0]).to  have_input(:status    , name: "i_register_1_status"    , width: 2)
      expect(rtl[0]).to  have_input(:read_data , name: "i_register_1_read_data" , width: 32)

      expect(rtl[1]).to have_output(:valid     , name: "o_register_2_valid"     , width: 1)
      expect(rtl[1]).to have_output(:write     , name: "o_register_2_write"     , width: 1)
      expect(rtl[1]).to have_output(:read      , name: "o_register_2_read"      , width: 1)
      expect(rtl[1]).to have_output(:address   , name: "o_register_2_address"   , width: 3)
      expect(rtl[1]).to have_output(:strobe    , name: "o_register_2_strobe"    , width: 4)
      expect(rtl[1]).to have_output(:write_data, name: "o_register_2_write_data", width: 32)
      expect(rtl[1]).to  have_input(:ready     , name: "i_register_2_ready"     , width: 1)
      expect(rtl[1]).to  have_input(:status    , name: "i_register_2_status"    , width: 2)
      expect(rtl[1]).to  have_input(:read_data , name: "i_register_2_read_data" , width: 32)

      expect(rtl[2]).to have_output(:valid     , name: "o_register_3_valid"     , width: 1)
      expect(rtl[2]).to have_output(:write     , name: "o_register_3_write"     , width: 1)
      expect(rtl[2]).to have_output(:read      , name: "o_register_3_read"      , width: 1)
      expect(rtl[2]).to have_output(:address   , name: "o_register_3_address"   , width: 4)
      expect(rtl[2]).to have_output(:strobe    , name: "o_register_3_strobe"    , width: 4)
      expect(rtl[2]).to have_output(:write_data, name: "o_register_3_write_data", width: 32)
      expect(rtl[2]).to  have_input(:ready     , name: "i_register_3_ready"     , width: 1)
      expect(rtl[2]).to  have_input(:status    , name: "i_register_3_status"    , width: 2)
      expect(rtl[2]).to  have_input(:read_data , name: "i_register_3_read_data" , width: 32)
    end

    describe "#generate_code" do
      let(:expected_code_0) do
        <<'CODE'
assign external_register_select[0] = register_select[1];
rggen_bus_exporter #(
  .DATA_WIDTH             (32),
  .LOCAL_ADDRESS_WIDTH    (8),
  .EXTERNAL_ADDRESS_WIDTH (2),
  .START_ADDRESS          (8'h04)
) u_register_1_bus_exporter (
  .clk          (clk),
  .rst_n        (rst_n),
  .i_valid      (command_valid),
  .i_select     (register_select[1]),
  .i_write      (write),
  .i_read       (read),
  .i_address    (address),
  .i_strobe     (strobe),
  .i_write_data (write_data),
  .o_ready      (external_register_ready[0]),
  .o_read_data  (register_read_data[1]),
  .o_status     (external_register_status[0]),
  .o_valid      (o_register_1_valid),
  .o_write      (o_register_1_write),
  .o_read       (o_register_1_read),
  .o_address    (o_register_1_address),
  .o_strobe     (o_register_1_strobe),
  .o_write_data (o_register_1_write_data),
  .i_ready      (i_register_1_ready),
  .i_read_data  (i_register_1_read_data),
  .i_status     (i_register_1_status)
);
CODE
      end

      let(:expected_code_1) do
        <<'CODE'
assign external_register_select[1] = register_select[2];
rggen_bus_exporter #(
  .DATA_WIDTH             (32),
  .LOCAL_ADDRESS_WIDTH    (8),
  .EXTERNAL_ADDRESS_WIDTH (3),
  .START_ADDRESS          (8'h08)
) u_register_2_bus_exporter (
  .clk          (clk),
  .rst_n        (rst_n),
  .i_valid      (command_valid),
  .i_select     (register_select[2]),
  .i_write      (write),
  .i_read       (read),
  .i_address    (address),
  .i_strobe     (strobe),
  .i_write_data (write_data),
  .o_ready      (external_register_ready[1]),
  .o_read_data  (register_read_data[2]),
  .o_status     (external_register_status[1]),
  .o_valid      (o_register_2_valid),
  .o_write      (o_register_2_write),
  .o_read       (o_register_2_read),
  .o_address    (o_register_2_address),
  .o_strobe     (o_register_2_strobe),
  .o_write_data (o_register_2_write_data),
  .i_ready      (i_register_2_ready),
  .i_read_data  (i_register_2_read_data),
  .i_status     (i_register_2_status)
);
CODE
      end

      let(:expected_code_2) do
        <<'CODE'
assign external_register_select[2] = register_select[3];
rggen_bus_exporter #(
  .DATA_WIDTH             (32),
  .LOCAL_ADDRESS_WIDTH    (8),
  .EXTERNAL_ADDRESS_WIDTH (4),
  .START_ADDRESS          (8'h10)
) u_register_3_bus_exporter (
  .clk          (clk),
  .rst_n        (rst_n),
  .i_valid      (command_valid),
  .i_select     (register_select[3]),
  .i_write      (write),
  .i_read       (read),
  .i_address    (address),
  .i_strobe     (strobe),
  .i_write_data (write_data),
  .o_ready      (external_register_ready[2]),
  .o_read_data  (register_read_data[3]),
  .o_status     (external_register_status[2]),
  .o_valid      (o_register_3_valid),
  .o_write      (o_register_3_write),
  .o_read       (o_register_3_read),
  .o_address    (o_register_3_address),
  .o_strobe     (o_register_3_strobe),
  .o_write_data (o_register_3_write_data),
  .i_ready      (i_register_3_ready),
  .i_read_data  (i_register_3_read_data),
  .i_status     (i_register_3_status)
);
CODE
      end

      it "バス出力モジュールをインスタンスするコードを生成する" do
        expect(rtl[0]).to generate_code(:module_item, :top_down, expected_code_0)
        expect(rtl[1]).to generate_code(:module_item, :top_down, expected_code_1)
        expect(rtl[2]).to generate_code(:module_item, :top_down, expected_code_2)
      end
    end
  end
end
