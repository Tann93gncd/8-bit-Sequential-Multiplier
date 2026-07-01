module bit_counter (
    input clk, rst,
    input clear, count_en,
    output reg [3:0] count,
    output last
);

    always @(posedge clk or posedge rst) begin

        if (rst)
            count <= 4'b0000;

        else if (clear)
            count <= 4'b0000;

        else if (count_en)
            count <= count + 1;

    end

    assign last = (count == 4'd7);

endmodule