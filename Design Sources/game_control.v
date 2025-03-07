`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2025 12:29:49 PM
// Design Name: 
// Module Name: game_control
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


module game_control(
    input clk,
    input reset,
    input btnU,
    input FlashTimeUp,
    input TimeUp,
    input separated,
    output freeze,
    output flash,
    output LD,
    output membrane_on,
    output an_flash,
    output [4:0] state
    );
    
    wire [4:0] D;
    wire [4:0] Q;
    
    // Q[0] = IDLE: No membrane, molecules are in fixed positions, green border is solid
    // Q[1] = BEFORE START: No membrane, molecules can now move, green border is flashing
    // Q[2] = GAME START: Membrane appears, green border is solid, timer starts
    // Q[3] = WIN: Membrane is unaffected by buttons, green border flashes, timer stops
    // Q[4] = TIME UP: Membrane is unaffected by buttons, hex display flashes 00
    
    FDRE #(.INIT(1'b1)) Q0_FF (
        .C(clk), .R(reset), .CE(1'b1),
        .D(D[0]), .Q(Q[0])
    );
    
    FDRE #(.INIT(1'b0)) Q41_FF [4:1] (
        .C({4{clk}}), .R({4{reset}}), .CE({4{1'b1}}),
        .D(D[4:1]), .Q(Q[4:1])
    );
    
    assign D[0] = Q[0] & ~btnU | reset;
    assign D[1] = Q[0] & btnU | Q[1] & ~FlashTimeUp | (Q[3] | Q[4]) & btnU;
    assign D[2] = Q[1] & FlashTimeUp | Q[2] & ~TimeUp & ~separated;
    assign D[3] = Q[2] & separated & ~TimeUp | Q[3] & ~btnU;
    assign D[4] = Q[2] & TimeUp | Q[4] & ~btnU;
    
    assign freeze = Q[0];
    assign flash = Q[1] | Q[3];
    assign LD = (Q[0] | Q[3] | Q[4]) & btnU;
    assign membrane_on = Q[2] | Q[3] | Q[4];
    assign an_flash = Q[4];
    
    assign state[4:0] = Q[4:0];
    
endmodule