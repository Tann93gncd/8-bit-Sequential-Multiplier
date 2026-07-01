`timescale 1ns/1ps

module tb_bit_counter;


    // Testbench Signals
    bit clk, rst, clear, count_en;
    bit [3:0] count;
    bit last;

    bit [3:0] expected_count;
    bit expected_last;

    // DUT Instantiation
    bit_counter dut (.clk(clk), .rst(rst), .clear(clear), .count_en(count_en),.count(count), .last(last));

    // Clock Generation : 10ns Period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task checker_scoreboard;
        input [3:0] expected_count;
        input expected_last;
        input string test_name;

        if(count == expected_count && last == expected_last)

            $display("%s Test Passed : count=%0d, last=%0b",
                     test_name, count, last);

        else

            $error("%s Test Failed : DUT -> count=%0d, last=%0b | Expected -> count=%0d, last=%0b",
                    test_name, count, last, expected_count, expected_last);

    endtask

    // Apply Inputs Task
    task apply_inputs;

        input bit rst_;
        input bit clear_;
        input bit count_en_;

        rst      = rst_;
        clear    = clear_;
        count_en = count_en_;

        @(posedge clk); // Wait for next positive edge
        #1;             // Propagation delay

        $display("Inputs Applied -> rst=%0b, clear=%0b, count_en=%0b",
                  rst, clear, count_en);

    endtask


    // Test Sequence
    initial begin
        // Initialization of DUT
        rst = 0;
        clear = 0;
        count_en = 0;

        // RESET TEST
        apply_inputs(1,0,0);
        apply_inputs(0,0,0);

        expected_count = 0;
        expected_last  = 0;

        checker_scoreboard(expected_count, expected_last, "Reset");

        // COUNT ENABLE TEST
        apply_inputs(0,0,1);
        apply_inputs(0,0,1);
        apply_inputs(0,0,1);

        expected_count = 3;
        expected_last  = 0;

        checker_scoreboard(expected_count, expected_last, "Count Enable");

        // HOLD TEST
        apply_inputs(0,0,0);
        apply_inputs(0,0,0);

        expected_count = 3;
        expected_last  = 0;

        checker_scoreboard(expected_count, expected_last, "Hold");

        // CLEAR TEST
        apply_inputs(0,1,0);
        apply_inputs(0,0,0);

        expected_count = 0;
        expected_last  = 0;

        checker_scoreboard(expected_count, expected_last, "Clear");

        // MAX COUNT TEST
        apply_inputs(0,0,1);
        apply_inputs(0,0,1);
        apply_inputs(0,0,1);
        apply_inputs(0,0,1);
        apply_inputs(0,0,1);
        apply_inputs(0,0,1);
        apply_inputs(0,0,1);

        expected_count = 7;
        expected_last  = 1;

        checker_scoreboard(expected_count, expected_last, "Max Count");


        // SATURATION AND LAST SIGNAL TEST
        apply_inputs(0,0,1);
        apply_inputs(0,0,1);
        apply_inputs(0,0,1);

        expected_count = 7;
        expected_last  = 1;

        checker_scoreboard(expected_count, expected_last, "Saturation and Last Signal");

        // RESET WITH NON-ZERO COUNT
        apply_inputs(1,0,0);
        apply_inputs(0,0,0);

        expected_count = 0;
        expected_last  = 0;

        checker_scoreboard(expected_count, expected_last, "Reset Non-Zero");

        //SYNCHRONOUS RESET TEST       
		apply_inputs(0,0,1);
        apply_inputs(0,0,1);
		apply_inputs(1,0,0);
		apply_inputs(0,0,0);

        expected_count = 0;
        expected_last  = 0;

        checker_scoreboard(expected_count, expected_last, "Synchronous Reset");

        // PRIORITY TEST : rst > clear > count_en
        apply_inputs(1,1,1);
        apply_inputs(0,1,1);

        expected_count = 0;
        expected_last  = 0;

        checker_scoreboard(expected_count, expected_last, "Priority Reset");

        // PRIORITY TEST : clear > count_en
        apply_inputs(0,1,1);

        expected_count = 0;
        expected_last  = 0;

        checker_scoreboard(expected_count, expected_last, "Priority Clear");

        // RANDOM / CORNER CASE TESTS
        repeat(10) begin

            apply_inputs(
                $urandom_range(0,1),
                $urandom_range(0,1),
                $urandom_range(0,1)
            );

            $display("Random Test -> count=%0d, last=%0b", count, last);

        end

      $finish;

    end

    // Waveform Dump
    initial begin
        $dumpfile("tb_bit_counter.vcd");
        $dumpvars(0, tb_bit_counter);
    end

    // Timeout Watchdog
    initial begin
        #100000;
        $error("ERROR : Simulation timeout!");
        $finish;
    end

endmodule