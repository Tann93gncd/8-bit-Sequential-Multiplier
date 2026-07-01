`timescale 1ns/1ps
module tb_controller;

	bit clk , rst, start , last, do_add ;
	bit load, add_en, shift, count_en, clear, done;

    bit expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done;

	controller dut ( .clk(clk), .rst(rst), .start(start), .last(last), .do_add(do_add), 
    .load(load), .add_en(add_en), .shift(shift),
     .count_en(count_en), .clear(clear), .done(done)		
	);

	// Dumpfile and dumpvars for waveform generation
	initial begin
		$dumpfile("controller_waves.vcd"); //Specifiy dumfile name
		$dumpvars(0,tb_controller); //dump all signals in testbench
	end

	 // Clock generation - 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

	task checker_scoreboard;

        input expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done;
        input string test_name;

        if(load==expected_load && add_en==expected_add_en && shift==expected_shift && count_en==expected_count_en && 
        clear==expected_clear && done==expected_done) 
        $display("%s Test Passed: load=%h, add_en=%h, shift=%h, count_en=%h, clear=%h, done=%h", 
        test_name, load, add_en, shift, count_en, clear, done);

        else $error(" %s Test Failed: DUT - load=%h, add_en=%h, shift=%h, count_en=%h, clear=%h, done=%h | Expected: load=%h, add_en=%h, shift=%h, count_en=%h, clear=%h, done=%h",
         test_name, load, add_en, shift, count_en, clear, done, expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done);

    endtask

    task apply_inputs;
        input bit rst_, start_, last_, do_add_;        

        rst = rst_;
        start = start_;
        last = last_;
        do_add = do_add_;         
        
        @(posedge clk); // Wait for the next positive edge of the clock
        #1; // Propagation delay
        $display("input applied rst=%b, start=%b, last=%b, do_add=%b", rst, start, last, do_add);
    endtask   

    initial begin

        apply_inputs(1, 0, 0, 0); // rst=1
        // Expected in IDLE: All outputs 0
        expected_load = 0; expected_add_en = 0; expected_shift = 0; 
        expected_count_en = 0; expected_clear = 0; expected_done = 0;
        checker_scoreboard(expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done, "1. Reset (IDLE)");


        apply_inputs(0, 1, 0, 0); // rst=0, start=1
        // Expected in LOAD: clear=1, load=1, everything else 0
        expected_load = 1; expected_add_en = 0; expected_shift = 0; 
        expected_count_en = 0; expected_clear = 1; expected_done = 0;
        checker_scoreboard(expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done, "2. Start (LOAD)");


        apply_inputs(0, 0, 0, 0); // Drop start signal
        // Expected in CHECK: All outputs 0
        expected_load = 0; expected_add_en = 0; expected_shift = 0; 
        expected_count_en = 0; expected_clear = 0; expected_done = 0;
        checker_scoreboard(expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done, "3. Auto-Move (CHECK)");


        apply_inputs(0, 0, 0, 1); // do_add=1
        // Expected in ADD: add_en=1, everything else 0
        expected_load = 0; expected_add_en = 1; expected_shift = 0; 
        expected_count_en = 0; expected_clear = 0; expected_done = 0;
        checker_scoreboard(expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done, "4. Do Add (ADD)");


        apply_inputs(0, 0, 0, 0); // Drop do_add
        // Expected in SHIFT: shift=1, count_en=1
        expected_load = 0; expected_add_en = 0; expected_shift = 1; 
        expected_count_en = 1; expected_clear = 0; expected_done = 0;
        checker_scoreboard(expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done, "5. Auto-Move (SHIFT)");


        apply_inputs(0, 0, 0, 0); // last=0
        // Expected in CHECK: All outputs 0
        expected_load = 0; expected_add_en = 0; expected_shift = 0; 
        expected_count_en = 0; expected_clear = 0; expected_done = 0;
        checker_scoreboard(expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done, "6. Loop Back (CHECK)");


        apply_inputs(0, 0, 0, 0); // do_add=0
        // Expected in SHIFT: shift=1, count_en=1
        expected_load = 0; expected_add_en = 0; expected_shift = 1; 
        expected_count_en = 1; expected_clear = 0; expected_done = 0;
        checker_scoreboard(expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done, "7. Skip Add (SHIFT)");


        apply_inputs(0, 0, 1, 0); // last=1
        // Expected in DONE: done=1
        expected_load = 0; expected_add_en = 0; expected_shift = 0; 
        expected_count_en = 0; expected_clear = 0; expected_done = 1;
        checker_scoreboard(expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done, "8. Final Bit (DONE)");


        apply_inputs(0, 0, 0, 0); // Drop last
        // Expected in IDLE: All outputs 0
        expected_load = 0; expected_add_en = 0; expected_shift = 0; 
        expected_count_en = 0; expected_clear = 0; expected_done = 0;
        checker_scoreboard(expected_load, expected_add_en, expected_shift, expected_count_en, expected_clear, expected_done, "9. Auto-Reset (IDLE)");

        #10 $finish;
    end

endmodule
