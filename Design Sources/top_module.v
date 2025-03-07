`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2025 11:51:48 PM
// Design Name: 
// Module Name: top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module(
    input clkin,
    input btnL, btnR, btnC, btnD, btnU,
    input [15:0] sw,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output Hsync,
    output Vsync,
    output [6:0] seg,
    output dp,
    output [3:0] an,
    output [15:0] led
    );

    wire clk;
    wire digsel;
    
    labVGA_clks not_so_slow(
        .clkin(clkin),
        .greset(btnC),
        .clk(clk),
        .digsel(digsel)
    );
    
    wire [9:0] h_cnt;
    wire [9:0] v_cnt;
    
    pixel_addr pixel_counter(
        .clk(clk),
        .reset(btnC),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );
    
    // Sync signal for flip flops
    wire hsync_int, vsync_int;
    
    sync sync_gen(
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .Hsync(hsync_int),
        .Vsync(vsync_int)
    );

    FDRE #(.INIT(1'b1)) hsync_ff (
        .C(clk), .R(btnC), .CE(1'b1),
        .D(hsync_int), .Q(Hsync)
    );
    
    FDRE #(.INIT(1'b1)) vsync_ff (
        .C(clk), .R(btnC), .CE(1'b1),
        .D(vsync_int), .Q(Vsync)
    );

    wire frame;
    assign frame = (v_cnt == 0) & (h_cnt == 0);
    
    // RGB sync signals for flip flops
    wire [3:0] red_signal;
    wire [3:0] green_signal;
    wire [3:0] blue_signal;
    
    wire [7:0] timer_output;
    wire half_sec;
    wire [4:0] state;
    wire an_flash;
    
    RGB rgb_gen(
        .clk(clk),
        .frame(frame),
        .reset(btnC),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .btnD(btnD),
        .sw(sw),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .vgaRed(red_signal),
        .vgaGreen(green_signal),
        .vgaBlue(blue_signal),
        .timer_output(timer_output),
        .led(led[7:0]),
        .half_sec(half_sec),
        .an_flash(an_flash),
        .state(state)
    );
    
    wire [3:0] ring_out;
    
    ring_counter ring_count(
        .clk(clk),
        .advance(digsel),
        .R(ring_out)
    );
    
    selector sel (
        .N(display_val),
        .sel(ring_out),
        .H(hex_in)
    );
    
    wire [3:0] hex_in;
    
    hex7seg hex7 (
        .d3(hex_in[3]),
        .d2(hex_in[2]),
        .d1(hex_in[1]),
        .d0(hex_in[0]),
        .CA(seg[0]), .CB(seg[1]), .CC(seg[2]), 
        .CD(seg[3]), .CE(seg[4]), .CF(seg[5]), 
        .CG(seg[6])
    );
    
    wire [15:0] display_val;
    assign display_val = {timer_output[7:4], timer_output[3:0], 4'b0000, 4'b0000};
    
    wire flash_bit;
    FDRE #(.INIT(1'b0)) flash_counter (
        .C(clk),
        .R(btnC),
        .CE(half_sec),
        .D(~flash_bit),
        .Q(flash_bit)
    );
    
    // an[3] and an[2] display timer and flash in state[4]
    wire flash_enable;
    assign flash_enable = an_flash & flash_bit;
    
    wire [3:0] an_control;
    assign an_control[3] = ring_out[3] & ~an_flash | ring_out[3] & flash_enable;
    assign an_control[2] = ring_out[2] & ~an_flash | ring_out[2] & flash_enable;
    assign an_control[1] = 1'b0;
    assign an_control[0] = 1'b0;
    
    assign an = ~an_control;
    
    assign dp = 1'b1;
    
    FDRE #(.INIT(1'b0)) red_ff[3:0] (
        .C({4{clk}}), .R({4{btnC}}), .CE({4{1'b1}}),
        .D(red_signal), .Q(vgaRed)
    );
    
    FDRE #(.INIT(1'b0)) green_ff[3:0] (
        .C({4{clk}}), .R({4{btnC}}), .CE({4{1'b1}}),
        .D(green_signal), .Q(vgaGreen)
    );
    
    FDRE #(.INIT(1'b0)) blue_ff[3:0] (
        .C({4{clk}}), .R({4{btnC}}), .CE({4{1'b1}}),
        .D(blue_signal), .Q(vgaBlue)
    );
    

endmodule
