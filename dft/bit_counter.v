module bit_counter (
    input clk, rst,
    input clear, count_en,
    // DFT signals
    input test_mode,      // Bypass clock gating
    input scan_enable,    // Shift vs. capture mode
    input [3:0] scan_in,  // Scan chain input

    output reg [3:0] count,
    output last
  );

  // Instantiate Integrated Clock Gate
  wire gated_clk;
  ICG u_icg (
    .clk(clk),
    .enable(count_en),
    .test_enable(test_mode),  // Bypass gate when test_mode=1
    .gated_clk(gated_clk)
  );

  // Functional next-state logic
  wire [3:0] count_next_func;
  assign count_next_func = (clear) ? 4'b0 : count + 1'b1;

  // Register with scan mux
  always @(posedge gated_clk) begin
    if (rst)
      count <= 4'b0;
    else
      count <= scan_enable ? scan_in : count_next_func;
  end

  // Combinational last signal
  assign last = (count == 4'd7);

endmodule
