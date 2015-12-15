require_relative '../spec_helper'

describe "register_block/module_declaration" do
  include_context 'configuration common'
  include_context 'register_map common'
  include_context 'rtl common'

  before(:all) do
    enable(:global, [:data_width, :address_width])
    enable(:register_block, [:name, :byte_size])
    enable(:register_block, [:module_declaration, :port_declarations, :clock_reset, :signal_declarations, :host_if, :response_mux])
    enable(:register_block, :host_if, :apb)
    enable(:register, [:name, :offset_address, :accessibility])
    enable(:register, [:address_decoder, :read_data])
    enable(:bit_field, [:name, :bit_assignment, :type, :initial_value, :reference])
    enable(:bit_field, :type, [:rw, :ro])

    configuration = create_configuration(address_width: 16)
    register_map  = create_register_map(
      configuration,
      "block_0" => [
        [nil, nil         , "block_0"                                       ],
        [nil, nil         , 256                                             ],
        [                                                                   ],
        [                                                                   ],
        [nil, "register_0", "0x00", "bit_field_0_0", "[16]"   , "rw", 0, nil],
        [nil, nil         , nil   , "bit_field_0_1", "[0]"    , "ro", 0, nil],
        [nil, "register_1", "0x04", "bit_field_1_0", "[31:16]", "ro", 0, nil],
        [nil, nil         , nil   , "bit_field_1_1", "[15:0]" , "rw", 0, nil]
      ]
    )

    @rtl  = build_rtl_factory.create(configuration, register_map).register_blocks[0]
  end

  after(:all) do
    clear_enabled_items
  end

  let(:rtl) do
    @rtl
  end

  describe "#write_file" do
    before do
      expect(File).to receive(:write).with("./block_0.sv", expected_code)
    end

    let(:expected_code) do
      <<'CODE'
module block_0 (
  input clk,
  input rst_n,
  input [15:0] i_paddr,
  input [2:0] i_pprot,
  input i_psel,
  input i_penable,
  input i_pwrite,
  input [31:0] i_pwdata,
  input [3:0] i_pstrb,
  output o_pready,
  output [31:0] o_prdata,
  output o_pslverr,
  output o_bit_field_0_0,
  input i_bit_field_0_1,
  input [15:0] i_bit_field_1_0,
  output [15:0] o_bit_field_1_1
);
  logic command_valid;
  logic write;
  logic read;
  logic [7:0] address;
  logic [31:0] write_data;
  logic [31:0] write_mask;
  logic response_ready;
  logic [31:0] read_data;
  logic [2:0] status;
  logic [1:0] register_select;
  logic [31:0] register_read_data[2];
  logic bit_field_0_0_value;
  logic bit_field_0_1_value;
  logic [15:0] bit_field_1_0_value;
  logic [15:0] bit_field_1_1_value;
  rgen_host_if_apb #(
    .DATA_WIDTH           (32),
    .HOST_ADDRESS_WIDTH   (16),
    .LOCAL_ADDRESS_WIDTH  (8)
  ) u_host_if (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_paddr          (i_paddr),
    .i_pprot          (i_pprot),
    .i_penable        (i_penable),
    .i_pwrite         (i_pwrite),
    .i_pwdata         (i_pwdata),
    .i_pstrb          (i_pstrb),
    .o_pready         (o_pready),
    .o_prdata         (o_prdata),
    .o_pslverr        (o_pslverr),
    .o_command_valid  (command_valid),
    .o_write          (write),
    .o_read           (read),
    .o_address        (address),
    .o_write_data     (write_data),
    .o_write_mask     (write_mask),
    .i_response_ready (response_ready),
    .i_read_data      (read_data),
    .i_status         (status)
  );
  rgen_response_mux #(
    .DATA_WIDTH       (32),
    .TOTAL_REGISTERS  (2)
  ) u_response_mux (
    .clk                  (clk),
    .rst_n                (rst_n),
    .i_command_valid      (command_valid),
    .o_response_ready     (response_ready),
    .o_read_data          (read_data),
    .o_status             (status),
    .i_register_select    (register_select),
    .i_register_read_data (register_read_data)
  );
  rgen_address_decoder #(
    .ADDRESS_WIDTH  (8),
    .READABLE       (1),
    .WRITABLE       (1),
    .START_ADDRESS  (8'h00),
    .END_ADDRESS    (8'h03)
  ) u_register_0_address_decoder (
    .i_address  (address),
    .i_read     (read),
    .i_write    (write),
    .o_select   (register_select[0])
  );
  assign register_read_data[0] = {15'h0000, bit_field_0_0_value, 15'h0000, bit_field_0_1_value};
  assign o_bit_field_0_0 = bit_field_0_0_value;
  rgen_bit_field_rw #(
    .WIDTH          (1),
    .INITIAL_VALUE  (1'h0)
  ) u_bit_field_0_0 (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_command_valid  (command_valid),
    .i_select         (register_select[0]),
    .i_write          (write),
    .i_write_data     (write_data[16]),
    .i_write_mask     (write_mask[16]),
    .o_value          (bit_field_0_0_value)
  );
  assign bit_field_0_1_value = i_bit_field_0_1;
  rgen_address_decoder #(
    .ADDRESS_WIDTH  (8),
    .READABLE       (1),
    .WRITABLE       (1),
    .START_ADDRESS  (8'h04),
    .END_ADDRESS    (8'h07)
  ) u_register_1_address_decoder (
    .i_address  (address),
    .i_read     (read),
    .i_write    (write),
    .o_select   (register_select[1])
  );
  assign register_read_data[1] = {bit_field_1_0_value, bit_field_1_1_value};
  assign bit_field_1_0_value = i_bit_field_1_0;
  assign o_bit_field_1_1 = bit_field_1_1_value;
  rgen_bit_field_rw #(
    .WIDTH          (16),
    .INITIAL_VALUE  (16'h0000)
  ) u_bit_field_1_1 (
    .clk              (clk),
    .rst_n            (rst_n),
    .i_command_valid  (command_valid),
    .i_select         (register_select[1]),
    .i_write          (write),
    .i_write_data     (write_data[15:0]),
    .i_write_mask     (write_mask[15:0]),
    .o_value          (bit_field_1_1_value)
  );
endmodule
CODE
    end

    it "レジスタモジュールのRTLを書き出す" do
      rtl.write_file
    end
  end
end
