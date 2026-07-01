module ICG (
  input clk,
  input enable,       // Functional enable (e.g., count_en)
  input test_enable,  // Test mode (bypass clock gating)
  output gated_clk
);

  // Latch-based clock gate (industry standard)
  // Latch opens when clk=0 to avoid glitches
  reg en_latch;

  always @(clk or enable or test_enable) begin
    if (!clk)
      en_latch = enable | test_enable;  // Bypass when test_enable=1
  end

  assign gated_clk = clk & en_latch;

endmodule

