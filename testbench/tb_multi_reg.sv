
`timescale 1ns/1ps
module tb_mult_regs;

    // Testbench signals
    bit clk,rst,load,add_en,shift;
    bit [7:0] a_in,b_in,M,Q;
    bit [8:0] A;
    
    bit [7:0] expected_Q, expected_M;
    bit [8:0] expected_A; // For checker-scoreboard
    // Instantiate DUT
    mult_regs dut (.clk(clk),.rst(rst),.load(load),.add_en(add_en),.shift(shift),.a_in(a_in),.b_in(b_in), .A(A),.M(M),.Q(Q));
    
    // Clock generation - 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task checker_scoreboard;
        input [8:0] expected_A;
        input [7:0] expected_M;
        input [7:0] expected_Q;
        input string test_name;

        if(A==expected_A && M==expected_M && Q==expected_Q) $display("%s Test Passed: A=%h, M=%h, Q=%h", test_name, A, M, Q);
        else $error(" %s Test Failed: DUT - A=%h, M=%h, Q=%h | Expected: A=%h, M=%h, Q=%h", test_name, A, M, Q, expected_A, expected_M, expected_Q);
    endtask

    task apply_inputs;
        input bit rst_, load_, add_en_, shift_;
        input [7:0] a_in_, b_in_;

        rst = rst_;
        load = load_;
        add_en = add_en_;
        shift = shift_;
        a_in = a_in_;
        b_in = b_in_; 
        
        @(posedge clk); // Wait for the next positive edge of the clock
        #1; // Propagation delay
        $display("input applied rst=%b, load=%b, add_en=%b, shift=%b, ain=%h, b_in=%h", rst, load, add_en, shift, a_in, b_in);
    endtask   
   // assign output_a= ain & bin;

    initial begin
        //intialization of DUT
     //   rst = 0; load = 0; add_en = 0; shift = 0; a_in = 0; b_in = 0;       //asynchronous reset test
     //   @(posedge clk); // Wait for the first positive edge of the clock
     //   #1;
     //   rst=1;
        //synchronous reset test
       // rst = 1; load = 0; add_en = 0; shift = 0; a_in = 0; b_in = 0;
       // repeat (1) @(posedge clk); // Wait for 1 clock cycles
       // #1; //propagation delay
        apply_inputs(1, 0, 0, 0, 0, 0); // Apply inputs for reset test
        
        apply_inputs(0, 0, 0, 0, 0, 0); // Apply inputs for load test
        expected_A = 0; expected_Q = 0; expected_M = 0; // Expected values after reset
        ///////////////////////
        ////checker-scoreboard//
        checker_scoreboard(expected_A, expected_M, expected_Q, "Reset");

        //load
        rst = 0; load = 1; add_en = 0; shift = 0; a_in = 10; b_in = 15;
        repeat (1) @(posedge clk); // event control system. 
        #1; //propagation delay
        expected_A = 0; expected_Q = 15; expected_M = 10; // Expected values after load
        ////checker-scoreboard//
        checker_scoreboard(expected_A, expected_M, expected_Q, "Load");

    
        repeat (1) @(posedge clk); // event control system. 
        #1; //propagation delay
        rst=1;
        #1;
        checker_scoreboard(expected_A, expected_M, expected_Q, "asynchrous-reset");
        
        @(posedge clk); // Wait for the first positive edge of the clock
        #1;
        expected_A = 0; expected_Q = 0; expected_M = 0; // Expected values after reset
        ///////////////////////
        ////checker-scoreboard//
        checker_scoreboard(expected_A, expected_M, expected_Q, "synchrous-reset");


        //add operation
        rst = 0; load = 1; add_en = 0; shift = 0; a_in = 10; b_in = 15;
        repeat (1) @(posedge clk); // event control system. 
        #1; //propagation delay
        expected_A = 0; expected_Q = 15; expected_M = 10; // Expected values after load
        ////checker-scoreboard//
        checker_scoreboard(expected_A, expected_M, expected_Q, "add - Load");

        rst = 0; load = 0; add_en = 1; shift = 0; 
        repeat (1) @(posedge clk); // event control system. 
        #1; //propagation delay
        expected_A = 10; expected_Q = 15; expected_M = 10; //
        checker_scoreboard(expected_A, expected_M, expected_Q, "add - 1st cycle");


        $finish;

        
    end

// --------------------------------------------------------------
  //  Waveform dump (optional : useful for visual debugging)
  // --------------------------------------------------------------
  initial begin
    $dumpfile("tb_multi_reg.vcd");
    $dumpvars(0, tb_mult_regs);
  end

    // Timeout watchdog
    initial begin
        #100000;
        $error(" ERROR: Simulation timeout!");
        $finish;
    end
    
endmodule









