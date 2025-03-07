`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2025 09:09:59 PM
// Design Name: 
// Module Name: LFSR_Y1
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


module LFSR_Y(
    input clk,
    input CE,
    output [9:0] rnd
    );
    
    wire [2:0] Q;  // Changed from 3:0 to 2:0 for 3-bit LFSR
    wire [2:0] D;  // Changed from 3:0 to 2:0 for 3-bit LFSR
    
    // Initialize 100
    FDRE #(.INIT(1'b1)) Q2_FF (
        .C(clk), .R(1'b0), .CE(CE),
        .D(D[2]), .Q(Q[2])
    );
    
    FDRE #(.INIT(1'b0)) Q10_FF[1:0] (
        .C({2{clk}}), .R({2{1'b0}}), .CE({2{CE}}),
        .D(D[1:0]), .Q(Q[1:0])
    );
    
    // 3-bit LFSR with taps at positions 2, 0
    assign D[2] = Q[0];
    assign D[1] = Q[2];
    assign D[0] = Q[1] ^ Q[0];  // XOR tap at position 1 and 0 (different from X LFSR)

    // Pad with zeros to maintain 10-bit output
    assign rnd = {7'b0000000, Q};
    
endmodule 