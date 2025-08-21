module impulse_generator #(
    parameter HOLD_TIME = 8 // impulse 신호를 몇 클럭 동안 유지할지
)(
    input wire clk,
    input wire reset,
    input wire fire,
    output reg synout
);
    reg [$clog2(HOLD_TIME) - 1:0] holdctr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            synout <= 0;
            holdctr <= 0;
        end else begin
            if (fire) begin
                synout <= 1'b1;
                holdctr <= HOLD_TIME - 1;
            end
            else if (holdctr > 0) begin
                synout <= 1'b1;
                holdctr <= holdctr - 1;
            end
            else begin
                synout <= 1'b0;
            end
        end
    end
endmodule