`default_nettype none

module NRZ_sequence #(
    parameter DURATION_CLK_COUNTS = 62,
    parameter CODE_0_HIGH_DURATION_CLK_COUNTS = 19,
    parameter CODE_1_HIGH_DURATION_CLK_COUNTS = 39
)(
    input  wire clk,
    input  wire reset,
    input  wire trigger,
    input  wire bit_to_code,
    output reg  seq = 1'b0
);

    reg [$clog2(DURATION_CLK_COUNTS)-1:0] step = 0;

    always @(posedge clk) begin
        if (reset) begin
            step <= 0;
        end else begin
          if (trigger == 1'b1)
              step <= 0;
          else if (step != DURATION_CLK_COUNTS)
              step <= step + 1'd1;
        end
    end

    always @(*) begin
        if ((bit_to_code == 1'b0 && step <= CODE_0_HIGH_DURATION_CLK_COUNTS) ||
            (bit_to_code == 1'b1 && step <= CODE_1_HIGH_DURATION_CLK_COUNTS))
            seq = 1'b1;
        else
            seq = 1'b0;
    end

endmodule
