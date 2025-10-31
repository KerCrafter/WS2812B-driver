module WS2812B_driver #(
    parameter MAX_POS = 16
)(
    input  wire clk,
    output reg  leds_line = 1'b0,
    input  wire update_frame,
    output reg [$clog2(MAX_POS)-1:0] program_led_number = 0,
    input  wire [7:0] program_red_intensity,
    input  wire [7:0] program_blue_intensity,
    input  wire [7:0] program_green_intensity
);

    localparam step_max = 62;
    localparam bit_proceed_max = 23;
    localparam [1:0] WaitTrigger = 2'b00;
    localparam [1:0] SendLEDsData = 2'b01;
    localparam [1:0] ValidateSeq = 2'b10;
    localparam [1:0] WaitTriggerRelease = 2'b11;
    localparam HIGH_DURATION_FOR_CODE_1 = 39;
    localparam HIGH_DURATION_FOR_CODE_0 = 19;

    reg [$clog2(step_max)-1:0] step = 0;
    reg [$clog2(bit_proceed_max)-1:0] bit_proceed = 0;
    reg [$clog2(2600)-1:0] reset_step = 0;
    reg [1:0] stage = WaitTrigger;
    reg seq_trigger;
    reg seq_bit_to_code;

    wire seq_line;  // <--- ajout d’un fil intermédiaire

    wire [23:0] data_concat = {program_green_intensity, program_red_intensity, program_blue_intensity};

    NRZ_sequence #(
        .DURATION_CLK_COUNTS(62),
        .CODE_1_HIGH_DURATION_CLK_COUNTS(39),
        .CODE_0_HIGH_DURATION_CLK_COUNTS(19)
    ) NRZ_sequence_inst (
        .clk(clk),
        .trigger(seq_trigger),
        .bit_to_code(seq_bit_to_code),
        .seq(seq_line)   // <--- on connecte ici le wire
    );

    // leds_line suit la sortie de la séquence
    always @(posedge clk)
        leds_line <= seq_line;

    always @(posedge clk) begin
        case (stage)
            WaitTrigger: begin
                if (update_frame == 1'b1) begin
                    seq_trigger <= 1'b1;
                    seq_bit_to_code <= data_concat[bit_proceed_max - bit_proceed];
                    stage <= SendLEDsData;
                end else begin
                    seq_trigger <= 1'b0;
                end
            end

            SendLEDsData: begin
                if (seq_trigger == 1'b1)
                    seq_trigger <= 1'b0;

                if (step == step_max) begin
                    step <= 0;
                    if (bit_proceed == bit_proceed_max) begin
                        bit_proceed <= 0;
                        if (program_led_number == MAX_POS - 1) begin
                            program_led_number <= 0;
                            stage <= ValidateSeq;
                        end else begin
                            program_led_number <= program_led_number + 1;
                            seq_bit_to_code <= data_concat[bit_proceed_max];
                            seq_trigger <= 1'b1;
                        end
                    end else begin
                        seq_trigger <= 1'b1;
                        bit_proceed <= bit_proceed + 1;
                        seq_bit_to_code <= data_concat[bit_proceed_max - (bit_proceed + 1)];
                    end
                end else begin
                    step <= step + 1;
                end
            end

            ValidateSeq: begin
                if (reset_step == 2600) begin
                    stage <= WaitTriggerRelease;
                    seq_trigger <= 1'b0;
                    reset_step <= 0;
                end else begin
                    reset_step <= reset_step + 1;
                end
            end

            WaitTriggerRelease: begin
                if (update_frame == 1'b0)
                    stage <= WaitTrigger;
            end
        endcase
    end

endmodule
