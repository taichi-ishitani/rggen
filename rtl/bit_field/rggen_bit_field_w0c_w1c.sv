module rggen_bit_field_w0c_w1c #(
  parameter WIDTH         = 1,
  parameter INITIAL_VALUE = 1'b0,
  parameter CLEAR_VALUE   = 0
)(
  input               clk,
  input               rst_n,
  input   [WIDTH-1:0] i_set,
  input               i_command_valid,
  input               i_select,
  input               i_write,
  input   [WIDTH-1:0] i_write_data,
  input   [WIDTH-1:0] i_write_mask,
  output  [WIDTH-1:0] o_value
);
  logic [WIDTH-1:0] value;
  logic             write_valid;

  assign  o_value     = value;
  assign  write_valid = (i_command_valid && i_select && i_write) ? 1'b1 : 1'b0;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      value <= INITIAL_VALUE;
    end
    else begin
      for (int i = 0;i < WIDTH;i++) begin
        if (i_set[i]) begin
          value[i]  <= 1'b1;
        end
        else if (write_valid && clear(i_write_mask[i], i_write_data[i])) begin
          value[i]  <= 1'b0;
        end
      end
    end
  end

  function automatic clear(input mask, input data);
    logic clear_value;
    clear_value = (CLEAR_VALUE == 1) ? 1'b1 : 1'b0;
    return (mask && (data == clear_value)) ? 1'b1 : 1'b0;
  endfunction
endmodule

