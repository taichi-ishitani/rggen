module rggen_response_mux #(
  parameter DATA_WIDTH      = 32,
  parameter TOTAL_REGISTERS = 1
)(
  input                         clk,
  input                         rst_n,
  input                         i_command_valid,
  input                         i_read,
  output                        o_response_ready,
  output  [DATA_WIDTH-1:0]      o_read_data,
  output  [1:0]                 o_status,
  input   [TOTAL_REGISTERS-1:0] i_register_select,
  input   [DATA_WIDTH-1:0]      i_register_read_data[TOTAL_REGISTERS]
);
  //  Response ready
  logic response_valid;
  logic response_ready;

  assign  o_response_ready  = response_ready;
  assign  response_valid    = (i_command_valid && (!response_ready)) ? 1'b1 : 1'b0;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      response_ready  <= 1'b0;
    end
    else if (response_valid) begin
      response_ready  <= 1'b1;
    end
    else begin
      response_ready  <= 1'b0;
    end
  end

  //  Status
  logic       slave_error;
  logic       exokay;
  logic [1:0] status;

  assign  o_status      = status;
  assign  slave_error   = (TOTAL_REGISTERS == 1) ? ~i_register_select[0] : ~|i_register_select;
  assign  exokay        = 1'b0;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      status  <= 2'b00;
    end
    else if (response_valid) begin
      status  <= {exokay, slave_error};
    end
    else begin
      status  <= 2'b00;
    end
  end

  //  Read data
  logic [DATA_WIDTH-1:0]  read_data;

  assign  o_read_data = read_data;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)  begin
      read_data <= '0;
    end
    else if (response_valid && i_read) begin
      read_data <= select_read_data(
        .select     (i_register_select    ),
        .read_data  (i_register_read_data )
      );
    end
    else begin
      read_data <= '0;
    end
  end

  function automatic logic [DATA_WIDTH-1:0] select_read_data(
    input logic [TOTAL_REGISTERS-1:0] select,
    input logic [DATA_WIDTH-1:0]      read_data[TOTAL_REGISTERS]
  );
    logic [DATA_WIDTH-1:0]  masked_read_data[TOTAL_REGISTERS];
    for (int i = 0;i < TOTAL_REGISTERS;i++) begin
      masked_read_data[i] = {DATA_WIDTH{select[i]}} & read_data[i];
    end
    return masked_read_data.or();
  endfunction
endmodule
