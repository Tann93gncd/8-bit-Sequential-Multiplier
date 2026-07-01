`timescale 1ns/1ps

module tb_add_decision;

    bit clk;
    bit [8:0] A;
    bit [7:0] M;
    bit Q_lsb;
    wire [8:0] sum;
    wire do_add;

    bit [8:0] expected_sum;
    bit expected_do_add;

    
    add_decision dut (
        .A(A),
        .M(M),
        .Q_lsb(Q_lsb),
        .sum(sum),
        .do_add(do_add)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    task checker_scoreboard;
        input [8:0] exp_sum;
        input exp_do_add;
        input string test_name;
        begin
            if (sum === exp_sum && do_add === exp_do_add)
                $display("%s Test Passed: sum=%d, do_add=%b", test_name, sum, do_add);
            else
                $error("%s Test Failed: DUT - sum=%d, do_add=%b | Expected: sum=%d, do_add=%b", 
                       test_name, sum, do_add, exp_sum, exp_do_add);
        end
    endtask

    
    task apply_inputs;
        input [8:0] a_in;
        input [7:0] m_in;
        input q_lsb_in;
        begin
            A = a_in;
            M = m_in;
            Q_lsb = q_lsb_in;
            @(posedge clk); // Wait for the clock edge for consistent timing
            #1;             // Small propagation delay 
            $display("Input applied: A=%d, M=%d, Q_lsb=%b", A, M, Q_lsb);
        end
    endtask

    initial begin
        $display("--- Starting add_decision Logic Tests ---");

        apply_inputs(9'd10, 8'd5, 1'b1);
        expected_sum = 15; expected_do_add = 1'b1;
        checker_scoreboard(expected_sum, expected_do_add, "Standard Addition");

        apply_inputs(9'd25, 8'd15, 1'b0);
        expected_sum = 40; expected_do_add = 1'b0;
        checker_scoreboard(expected_sum, expected_do_add, "Skip Addition Flag");

        apply_inputs(9'd511, 8'd255, 1'b1);
        expected_sum = 766; expected_do_add = 1'b1;
        checker_scoreboard(expected_sum, expected_do_add, "Max Carry Overflow Check");

        apply_inputs(9'd0, 8'd0, 1'b0);
        expected_sum = 0; expected_do_add = 1'b0;
        checker_scoreboard(expected_sum, expected_do_add, "Zero Input Logic");

        $display("--- All add_decision tests completed ---");
        $finish;
    end

    initial begin
        $dumpfile("add_decision_tb_gtk.vcd");
        $dumpvars(0, tb_add_decision);
    end

    initial begin
        #100000;
        $error(" ERROR: Simulation timeout!");
        $finish;
    end

endmodule