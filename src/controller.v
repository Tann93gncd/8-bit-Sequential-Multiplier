module controller (
    input clk, rst,
    input start, last, do_add,
    output reg load, add_en, shift, count_en, clear, done
);
    reg [2:0] state, next_state;
    parameter IDLE = 3'b000, LOAD = 3'b001, CHECK = 3'b010, 
              ADD = 3'b011, SHIFT = 3'b100, DONE = 3'b101;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end


    always @(*) begin

        load = 0; add_en = 0; shift = 0; count_en = 0; clear = 0; done = 0;
        next_state = state; 

        case (state)
            IDLE: begin                
                if (start) next_state = LOAD;
            end
            LOAD: begin
                clear = 1;
                load = 1; 
                next_state = CHECK;
            end
            CHECK: begin
                if (do_add) next_state = ADD;
                else next_state = SHIFT;
            end
            ADD: begin
                add_en = 1;
                next_state = SHIFT;
            end
            SHIFT: begin
                shift = 1;
                count_en = 1;
                if (last) next_state = DONE;
                else next_state = CHECK;
            end
            DONE: begin
                done = 1;
                next_state = IDLE;
            end
        endcase
    end
endmodule