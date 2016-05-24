module rggen_response_mux #(
  parameter DATA_WIDTH                = 32,
  parameter TOTAL_REGISTERS           = 1,
  parameter TOTAL_EXTERNAL_REGISTERS  = 0,
  parameter EXTERNAL_REGISTERS        = TOTAL_EXTERNAL_REGISTERS
                                      + ((TOTAL_EXTERNAL_REGISTERS == 0) ? 1 : 0)
)(
  input                             clk,
  input                             rst_n,
  input                             i_command_valid,
  input                             i_read,
  output                            o_response_ready,
  output  [DATA_WIDTH-1:0]          o_read_data,
  output  [1:0]                     o_status,
  input   [TOTAL_REGISTERS-1:0]     i_register_select,
  input   [DATA_WIDTH-1:0]          i_register_read_data[TOTAL_REGISTERS],
  input   [EXTERNAL_REGISTERS-1:0]  i_external_register_select,
  input   [EXTERNAL_REGISTERS-1:0]  i_external_register_ready,
  input   [1:0]                     i_external_register_status[EXTERNAL_REGISTERS]
);
  //  Response ready
  logic internal_ready;
  logic external_ready;
  logic response_valid;
  logic response_ready;

  assign  internal_ready  = (TOTAL_EXTERNAL_REGISTERS > 0) ? ~|i_external_register_select : 1'b1;
  assign  external_ready  = (TOTAL_EXTERNAL_REGISTERS > 0) ?  |i_external_register_ready  : 1'b0;
  assign  response_valid  = i_command_valid & (internal_ready | external_ready) & (~response_ready);

  assign  o_response_ready  = response_ready;
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
  logic [1:0] status;

  assign  o_status      = status;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      status  <= 2'b00;
    end
    else if (response_valid) begin
      status  <= get_internal_response(i_register_select)
               | get_external_response(i_external_register_select, i_external_register_status);
    end
    else begin
      status  <= 2'b00;
    end
  end

  function automatic logic [1:0] get_internal_response(
    input [TOTAL_REGISTERS-1:0] register_select
  );
    logic slave_error;
    logic exokay;
    slave_error = ~|register_select;
    exokay      = 1'b0;
    return {exokay, slave_error};
  endfunction

  function automatic logic [1:0] get_external_response(
    input [EXTERNAL_REGISTERS-1:0]  external_register_select,
    input [1:0]                     external_register_status[EXTERNAL_REGISTERS]
  );
    if (TOTAL_EXTERNAL_REGISTERS > 0) begin
      logic [1:0] masked_status[TOTAL_EXTERNAL_REGISTERS];
      for (int i = 0;i < TOTAL_EXTERNAL_REGISTERS;i++) begin
        masked_status[i]  = {2{external_register_select[i]}} & external_register_status[i];
      end
      return masked_status.or();
    end
    else begin
      return 2'b00;
    end
  endfunction

  //  Read data
  logic [DATA_WIDTH-1:0]  read_data;

  assign  o_read_data = read_data;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)  begin
      read_data <= '0;
    end
    else if (response_valid && i_read) begin
      read_data <= get_read_data(i_register_select, i_register_read_data);
    end
    else begin
      read_data <= '0;
    end
  end

  function automatic logic [DATA_WIDTH-1:0] get_read_data(
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
