module countUD5L(
    input clk,
    input Up,
    input Dw,
    input LD,
    input [4:0]Din,

    output [4:0]Q,
    output UTC,
    output DTC
);

    wire [4:0] D;
    wire [4:0] incr, decr;
    wire [4:0] carries;
    wire [4:0] borrows;
    
    FA FA0(
        .a(Q[0]),
        .b(1'b1),
        .Cin(1'b0),
        .s(incr[0]),
        .Cout(carries[0])
    );
    
    FA FA1(
        .a(Q[1]),
        .b(1'b0),
        .Cin(carries[0]),
        .s(incr[1]),
        .Cout(carries[1])
    );
    
    FA FA2(
        .a(Q[2]),
        .b(1'b0),
        .Cin(carries[1]),
        .s(incr[2]),
        .Cout(carries[2])
    );
    
    FA FA3(
        .a(Q[3]),
        .b(1'b0),
        .Cin(carries[2]),
        .s(incr[3]),
        .Cout(carries[3])
    );
    
    FA FA4(
        .a(Q[4]),
        .b(1'b0),
        .Cin(carries[3]),
        .s(incr[4]),
        .Cout(carries[4])
    );
    
    FS FS0(
        .a(Q[0]),
        .b(1'b1),
        .Bin(1'b0),
        .d(decr[0]),
        .Bout(borrows[0])
    );
    
    FS FS1(
        .a(Q[1]),
        .b(1'b0),
        .Bin(borrows[0]),
        .d(decr[1]),
        .Bout(borrows[1])
    );
    
    FS FS2(
        .a(Q[2]),
        .b(1'b0),
        .Bin(borrows[1]),
        .d(decr[2]),
        .Bout(borrows[2])
    );
    
    FS FS3(
        .a(Q[3]),
        .b(1'b0),
        .Bin(borrows[2]),
        .d(decr[3]),
        .Bout(borrows[3])
    );
    
    FS FS4(
        .a(Q[4]),
        .b(1'b0),
        .Bin(borrows[3]),
        .d(decr[4]),
        .Bout(borrows[4])
    );

    assign UTC = (Q == 5'b11111);
    assign DTC = (Q == 5'b00000);

    FDRE #(.INIT(1'b0)) Q0_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(D[0]), .Q(Q[0]));
    FDRE #(.INIT(1'b0)) Q1_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(D[1]), .Q(Q[1]));
    FDRE #(.INIT(1'b0)) Q2_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(D[2]), .Q(Q[2]));
    FDRE #(.INIT(1'b0)) Q3_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(D[3]), .Q(Q[3]));
    FDRE #(.INIT(1'b0)) Q4_FF (.C(clk), .R(1'b0), .CE(1'b1), .D(D[4]), .Q(Q[4]));
    
    wire [4:0] load_val = Din & {5{LD}};
    wire [4:0] incr_val = incr & {5{Up & ~Dw & ~LD}};
    wire [4:0] decr_val = decr & {5{~Up & Dw & ~LD}};
    wire [4:0] hold_val = Q & {5{~(LD | (Up & ~Dw) | (~Up & Dw))}};
    
    assign D = (load_val | incr_val | decr_val | hold_val);

endmodule

module FA(
    input a,     
    input b,      
    input Cin,   
    output s,    
    output Cout  
);

    assign s = a ^ b ^ Cin;
    
    assign Cout = (a & b) | (Cin & (a ^ b));

endmodule

module FS(
    input a,
    input b,
    input Bin,
    output d,
    output Bout
);
    assign d = a ^ b ^ Bin;
    assign Bout = (~a & b) | (Bin & ~a) | (Bin & b);

endmodule 
