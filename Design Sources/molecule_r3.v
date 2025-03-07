module molecule_r3(
    input clk,
    input frame,
    input reset,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input magenta_membrane,
    input red_membrane,
    input blue_membrane,
    input no_membrane,
    input membrane_on,
    input freeze,
    input btnD,
    output is_red,
    output is_molecule,
    output [9:0] pos_x_r3,
    output [9:0] pos_y_r3    
    );
    
    assign is_red = 1'b1;

    molecule_move_3 move_inst_3(
        .clk(clk),
        .frame(frame),
        .reset(reset),
        .magenta_membrane(magenta_membrane),
        .red_membrane(red_membrane),
        .blue_membrane(blue_membrane),
        .is_red(is_red),
        .no_membrane(no_membrane),
        .membrane_on(membrane_on),
        .freeze(freeze),
        .btnD(btnD),
        .pos_x(pos_x_r3),
        .pos_y(pos_y_r3)
    );
    
    wire [9:0] MOL_SIZE = 10'd16;
    
    wire h_match;
    wire v_match;
    
    assign h_match = (h_cnt >= pos_x_r3) & (h_cnt < pos_x_r3 + MOL_SIZE);
    assign v_match = (v_cnt >= pos_y_r3) & (v_cnt < pos_y_r3 + MOL_SIZE);
    
    assign is_molecule = h_match & v_match;
    
endmodule
