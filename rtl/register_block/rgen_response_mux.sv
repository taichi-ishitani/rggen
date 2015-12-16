module rgen_response_mux #(
  parameter DATA_WIDTH      = 32,
  parameter TOTAL_REGISTERS = 1
)(
  input                         clk,
  input                         rst_n,
  input                         i_command_valid,
  output                        o_response_ready,
  output  [DATA_WIDTH-1:0]      o_read_data,
  output  [2:0]                 o_status,
  input   [TOTAL_REGISTERS-1:0] i_regiter_select,
  input   [DATA_WIDTH-1:0]      i_register_read_data[TOTAL_REGISTERS]
);
  //  Response ready
  logic response_ready;

  assign  o_response_ready  = response_ready;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      response_ready  <= 1'b0;
    end
    else begin
      response_ready  <= i_command_valid;
    end
  end

  //  Status
  logic       slave_error;
  logic       decode_error;
  logic       exokay;
  logic [2:0] status;

  assign  o_status      = status;
  assign  slave_error   = ~|i_regiter_select;
  assign  decode_error  = 1'b0;
  assign  exokay        = 1'b0;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      status  <= 3'b000;
    end
    else if (i_command_valid) begin
      status  <= {exokay, decode_error, slave_error};
    end
    else begin
      status  <= 3'b000;
    end
  end

  //  Read data
  logic [DATA_WIDTH-1:0]  read_data;
  logic [DATA_WIDTH-1:0]  selected_data;

  assign  o_read_data = read_data;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)  begin
      read_data <= {DATA_WIDTH{1'b0}};
    end
    else if (i_command_valid) begin
      read_data <= selected_data;
    end
    else begin
      read_data <= {DATA_WIDTH{1'b0}};
    end
  end

  for (genvar i = 0;i < DATA_WIDTH;i++) begin
    logic [TOTAL_REGISTERS-1:0] temp;
    assign  selected_data[i]  = |temp;
    for (genvar j = 0;j < TOTAL_REGISTERS;j++) begin
      assign  temp[j] = i_regiter_select[j] & i_register_read_data[j][i];
    end
  end
endmodule
