module mult_regs (
    input clk, rst,
    input load, add_en, shift,
    input [7:0] a_in, b_in,
    input [8:0] sum,
    output reg [8:0] A,
    output reg [7:0] M, Q
);
    always @(posedge clk) begin
        if(rst) begin
            A <= 9'b0;
            Q <= 8'b0;
            M <= 8'b0;
        end
        else if(load) begin
            M <= a_in;
            Q <= b_in;
            A <= 9'b0;  
        end
        else if(add_en) begin
            A <= sum;
        end
        else if(shift) begin
            {A, Q} <= {A, Q} >> 1; 
        end
    end
endmodule

