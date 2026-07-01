module seq_multiplier (
	input clk, rst, start,
	input [7:0] a, b,
	output [15:0] product,
	output done
);
	// 1-Bit Control and Status Wires
	wire load, add_en, shift, count_en, clear, do_add, last;
	wire [8:0] A, sum;
	wire [7:0] M, Q;
	wire [3:0] count; 

	// U1: mult_regs (datapath registers)
	mult_regs U1 (
		.clk(clk),
		.rst(rst),
		.load(load),
		.add_en(add_en),
		.shift(shift),
		.a_in(a),
		.b_in(b),
		.sum(sum), // from add_decision
		.A(A),
		.M(M),
		.Q(Q)
	);

	// U2: bit_counter (counter)
	bit_counter U2 (
		.clk(clk),
		.rst(rst),
		.count_en(count_en),
		.clear(clear),
		.count(count),
		.last(last)
	);

	// U3: add_decision (combinational adder - NEW!)
	add_decision U3 (
		.A(A),
		.M(M),
		.Q_lsb(Q[0]),
		.sum(sum),
		.do_add(do_add)
	);

	// U4: controller (FSM)
	controller U4 (
		.clk(clk),
		.rst(rst),
		.start(start),
		.last(last),
		.do_add(do_add),
		.load(load),
		.add_en(add_en),
		.shift(shift),
		.count_en(count_en),
		.clear(clear),
		.done(done)
	);

	// Key signals to connect:
	assign product = {A[7:0], Q};

endmodule
