module molecule_r2(
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
    output [9:0] pos_x_r2,
    output [9:0] pos_y_r2    
    );

    assign is_red = 1'b1;

    molecule_move_2 move_inst_2(
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
        .pos_x(pos_x_r2),
        .pos_y(pos_y_r2)
    );
    
    wire [9:0] MOL_SIZE = 10'd16;
    
    wire h_match;
    wire v_match;
    
    assign h_match = (h_cnt >= pos_x_r2) & (h_cnt < pos_x_r2 + MOL_SIZE);
    assign v_match = (v_cnt >= pos_y_r2) & (v_cnt < pos_y_r2 + MOL_SIZE);
    
    assign is_molecule = h_match & v_match;
    
endmodule
