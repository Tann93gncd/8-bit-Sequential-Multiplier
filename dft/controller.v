module controller (
  input clk, rst,
  input start, last, q_lsb,
  // DFT signals
  input scan_enable,
  input [2:0] scan_in,

  output reg load, add_en, shift, count_en, clear, done,
  output reg [2:0] state  // Exposed for scan chain
);

  localparam IDLE  = 3'd0,
             LOAD  = 3'd1,
             CHECK = 3'd2,
             ADD   = 3'd3,
             SHIFT = 3'd4,
             DONE  = 3'd5;

  reg [2:0] next;

  // Next-state logic (combinational)
  always @(*) begin
    case (state)
      IDLE : next = start ? LOAD : IDLE;
      LOAD : next = CHECK;
      CHECK: next = q_lsb ? ADD : SHIFT;
      ADD  : next = SHIFT;
      SHIFT: next = last ? DONE : CHECK;
      DONE : next = IDLE;
      default: next = IDLE;
    endcase
  end

  // State register with scan mux
  always @(posedge clk) begin
    if (rst)
      state <= IDLE;
    else
      state <= scan_enable ? scan_in : next;
  end

  // Output logic (combinational Moore outputs)
  always @(*) begin
    {load, add_en, shift, count_en, clear, done} = 6'b0;
    case (state)
      LOAD : begin load = 1'b1; clear = 1'b1; end
      ADD  : add_en = 1'b1;
      SHIFT: begin shift = 1'b1; count_en = 1'b1; end
      DONE : done = 1'b1;
      default: ;
    endcase
  end

endmodule
