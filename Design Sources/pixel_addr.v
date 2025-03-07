module pixel_addr(
    input clk,
    input reset,
    output [9:0] h_cnt,
    output [9:0] v_cnt
    );

    wire [9:0] HD;
    wire [9:0] HQ;

    wire [9:0] VD;
    wire [9:0] VQ;

    wire HR, H_max;
    wire VR, V_max;

    FDRE #(.INIT(1'b0)) H_FF[9:0] (
        .C({10{clk}}), .R({10{HR | reset}}), .CE({10{1'b1}}),
        .D(HD[9:0]), .Q(HQ[9:0])
    );

    FDRE #(.INIT(1'b0)) V_FF[9:0] (
        .C({10{clk}}), .R({10{VR | reset}}), .CE({10{H_max}}),
        .D(VD[9:0]), .Q(VQ[9:0])
    );

    assign H_max = HQ == 10'd799;
    assign V_max = VQ == 10'd524;

    assign HR = H_max;
    assign VR = V_max & H_max;

    assign h_cnt = HQ;
    assign v_cnt = VQ;

    // Horizontal counter
    assign HD[0] = ~HQ[0];
    assign HD[1] = (HQ[1] & ~HQ[0]) | (~HQ[1] & HQ[0]);
    assign HD[2] = (HQ[2] & ~(HQ[1] & HQ[0])) | (~HQ[2] & HQ[1] & HQ[0]);
    assign HD[3] = (HQ[3] & ~(HQ[2] & HQ[1] & HQ[0])) | (~HQ[3] & HQ[2] & HQ[1] & HQ[0]);
    assign HD[4] = (HQ[4] & ~(HQ[3] & HQ[2] & HQ[1] & HQ[0])) | (~HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0]);
    assign HD[5] = (HQ[5] & ~(HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0])) | (~HQ[5] & HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0]);
    assign HD[6] = (HQ[6] & ~(HQ[5] & HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0])) | (~HQ[6] & HQ[5] & HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0]);
    assign HD[7] = (HQ[7] & ~(HQ[6] & HQ[5] & HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0])) | (~HQ[7] & HQ[6] & HQ[5] & HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0]);
    assign HD[8] = (HQ[8] & ~(HQ[7] & HQ[6] & HQ[5] & HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0])) | (~HQ[8] & HQ[7] & HQ[6] & HQ[5] & HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0]);
    assign HD[9] = (HQ[9] & ~(HQ[8] & HQ[7] & HQ[6] & HQ[5] & HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0])) | (~HQ[9] & HQ[8] & HQ[7] & HQ[6] & HQ[5] & HQ[4] & HQ[3] & HQ[2] & HQ[1] & HQ[0]);

    // Vertical counter
    assign VD[0] = ~VQ[0];
    assign VD[1] = (VQ[1] & ~VQ[0]) | (~VQ[1] & VQ[0]);
    assign VD[2] = (VQ[2] & ~(VQ[1] & VQ[0])) | (~VQ[2] & VQ[1] & VQ[0]);
    assign VD[3] = (VQ[3] & ~(VQ[2] & VQ[1] & VQ[0])) | (~VQ[3] & VQ[2] & VQ[1] & VQ[0]);
    assign VD[4] = (VQ[4] & ~(VQ[3] & VQ[2] & VQ[1] & VQ[0])) | (~VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0]);
    assign VD[5] = (VQ[5] & ~(VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0])) | (~VQ[5] & VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0]);
    assign VD[6] = (VQ[6] & ~(VQ[5] & VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0])) | (~VQ[6] & VQ[5] & VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0]);
    assign VD[7] = (VQ[7] & ~(VQ[6] & VQ[5] & VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0])) | (~VQ[7] & VQ[6] & VQ[5] & VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0]);
    assign VD[8] = (VQ[8] & ~(VQ[7] & VQ[6] & VQ[5] & VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0])) | (~VQ[8] & VQ[7] & VQ[6] & VQ[5] & VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0]);
    assign VD[9] = (VQ[9] & ~(VQ[8] & VQ[7] & VQ[6] & VQ[5] & VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0])) | (~VQ[9] & VQ[8] & VQ[7] & VQ[6] & VQ[5] & VQ[4] & VQ[3] & VQ[2] & VQ[1] & VQ[0]);

endmodule
