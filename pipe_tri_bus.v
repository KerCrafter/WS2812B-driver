`default_nettype none

module pipe_tri_bus (
    input  wire enable,
    input  wire [7:0] i_led_green_intensity,
    input  wire [7:0] i_led_red_intensity,
    input  wire [7:0] i_led_blue_intensity,
    input  wire [7:0] d_led_green_intensity,
    input  wire [7:0] d_led_red_intensity,
    input  wire [7:0] d_led_blue_intensity,
    output wire [7:0] o_led_green_intensity,
    output wire [7:0] o_led_red_intensity,
    output wire [7:0] o_led_blue_intensity
);

    assign o_led_green_intensity = (enable == 1'b1) ? d_led_green_intensity : i_led_green_intensity;
    assign o_led_red_intensity   = (enable == 1'b1) ? d_led_red_intensity   : i_led_red_intensity;
    assign o_led_blue_intensity  = (enable == 1'b1) ? d_led_blue_intensity  : i_led_blue_intensity;

endmodule
