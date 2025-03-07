module countUD15L(
    input clk,
    input Up,
    input Dw,
    input LD,
    input [14:0]Din,

    output [14:0]Q,
    output UTC,
    output DTC
);

    wire UTC0, UTC1, UTC2;
    wire DTC0, DTC1, DTC2;

    countUD5L count0(
        .clk(clk),
        .Up(Up),
        .Dw(Dw),
        .LD(LD),
        .Din(Din[4:0]),
        .Q(Q[4:0]),
        .UTC(UTC0),
        .DTC(DTC0)
    );

    countUD5L count1(
        .clk(clk),
        .Up(Up & UTC0),
        .Dw(Dw & DTC0),
        .LD(LD),
        .Din(Din[9:5]),
        .Q(Q[9:5]),
        .UTC(UTC1),
        .DTC(DTC1)
    );

    countUD5L count2(
        .clk(clk),
        .Up(Up & UTC0 & UTC1),
        .Dw(Dw & DTC0 & DTC1),
        .LD(LD),
        .Din(Din[14:10]),
        .Q(Q[14:10]),
        .UTC(UTC2),
        .DTC(DTC2)
    );

    assign UTC = UTC0 && UTC1 && UTC2;
    assign DTC = DTC0 && DTC1 && DTC2;

endmodule
