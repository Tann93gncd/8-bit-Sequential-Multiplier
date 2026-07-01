//Self-Checking Testbench
/*
This testbench should be used to test your sequential multiplier. 
It applies a few test cases and checks the results automatically, 
printing PASS or FAIL messages. You can add more test cases by calling 
the run task with different values of a and b. You can also view the waveforms in GTKWave 
by opening the generated multiplier_tb_gtk.vcd file.
*/

module tb_seq_multiplier;

	reg clk = 0, rst = 1, start = 0;
	reg [7:0] a, b;
	wire [15:0] product;
	wire done;

	seq_multiplier dut (
		.clk(clk),
		.rst(rst),
		.start(start),
		.a(a),
		.b(b),
		.product(product),
		.done(done)
	);

	// Dumpfile and dumpvars for waveform generation
	initial begin
		$dumpfile("multiplier_tb_gtk.vcd"); //Specifiy dumfile name
		$dumpvars(0,tb_seq_multiplier); //dump all signals in testbench
	end

	always #5 clk = ~clk;

	task run(input [7:0] x, input [7:0] y);
		begin
			@(negedge clk);
			a = x;
			b = y;
			start = 1;
			@(negedge clk);
			start = 0;
			wait(done);
			if (product !== x*y)
				$display("FAIL %0d * %0d = %0d (got %0d)", x, y, x*y, product);
			else
				$display("PASS %0d * %0d = %0d", x, y, product);
			@(negedge clk);
		end
	endtask

	initial begin
		#12 rst = 0;

		run(13, 11);
		run(0, 0);
		run(255, 255);
		run(1, 255);
		run(128, 2);

		$finish;
	end

endmodule
