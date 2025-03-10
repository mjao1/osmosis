module molecule_move_2(
    input clk,
    input frame,
    input reset,
    input magenta_membrane,
    input red_membrane,
    input blue_membrane,
    input is_red,
    input no_membrane,
    input membrane_on,
    input freeze,
    input btnD,
    output [9:0] pos_x,
    output [9:0] pos_y
    );

    wire [9:0] MOL_SIZE = 10'd16;
    
    wire hit_left, hit_right, hit_top, hit_bottom;

    wire hit_left_red, hit_right_red; 
    wire hit_left_blue, hit_right_blue;
    
    assign hit_left = (pos_x < 10'd8);
    assign hit_right = (pos_x > (10'd639 - 10'd8 - MOL_SIZE));
    assign hit_top = (pos_y < 10'd8);
    assign hit_bottom = (pos_y > (10'd479 - 10'd8 - MOL_SIZE));

    assign hit_left_red = (pos_x + MOL_SIZE == 10'd314) & 
                          (v_x[9] == 1'b0) & 
                          ((red_membrane & is_red & ~no_membrane) | (magenta_membrane & is_red & ~no_membrane)) & membrane_on;
    

    assign hit_right_red = (pos_x == 10'd323) & 
                           (v_x[9] == 1'b1) &
                           ((red_membrane & is_red & ~no_membrane) | (magenta_membrane & is_red & ~no_membrane)) & membrane_on;

    assign hit_left_blue = (pos_x + MOL_SIZE == 10'd314) & 
                           (v_x[9] == 1'b0) & 
                           ((blue_membrane & ~is_red & ~no_membrane) | (magenta_membrane & ~is_red & ~no_membrane)) & membrane_on;

    assign hit_right_blue = (pos_x == 10'd323) & 
                            (v_x[9] == 1'b1) &
                            ((blue_membrane & ~is_red & ~no_membrane) | (magenta_membrane & ~is_red & ~no_membrane)) & membrane_on;
    
    wire [9:0] v_x;
    wire [9:0] v_y;
    
    wire [9:0] next_v_x, next_v_y;
    
    assign next_v_x = (({10{hit_left}} | {10{hit_right_red}} | {10{hit_right_blue}}) & 10'b0000000001) | 
                      (({10{hit_right}} | {10{hit_left_red}} | {10{hit_left_blue}}) & 10'b1111111111) | 
                      (~{10{hit_left}} & ~{10{hit_right}} & ~{10{hit_right_red}} & ~{10{hit_right_blue}} & ~{10{hit_left_red}} & ~{10{hit_left_blue}} & v_x);

    assign next_v_y = ({10{hit_top}} & 10'b0000000001) | ({10{hit_bottom}} & 10'b1111111111) | (~{10{hit_top}} & ~{10{hit_bottom}} & v_y);


    wire [9:0] next_pos_x, next_pos_y;
    assign next_pos_x = (pos_x + v_x) & ~freeze | (pos_x & freeze);
    assign next_pos_y = (pos_y + v_y) & ~freeze | (pos_y & freeze);
    
    wire [9:0] rnd_pos_x;
    wire [9:0] rnd_pos_y;

    LFSR_X lfsr_x(
        .clk(clk),
        .CE(frame),
        .rnd(rnd_pos_x)
    );

    LFSR_Y lfsr_y(
        .clk(clk),
        .CE(frame),
        .rnd(rnd_pos_y)
    );

    wire load_init_pos;

    assign load_init_pos = reset | freeze;

    // Edge detector for btnD
    wire btnD_prev;
    wire btnD_edge;
    wire btnD_state;

    FDRE #(.INIT(1'b0)) btnD_prev_reg (.C(clk), .R(reset), .CE(1'b1), .D(btnD), .Q(btnD_prev));
    assign btnD_edge = btnD & ~btnD_prev;    

    FDRE #(.INIT(1'b0)) btnD_reg (.C(clk), .R(reset), .CE(btnD_edge), .D(~btnD_state), .Q(btnD_state));

    // Register to capture LFSR values
    wire [9:0] stored_rnd_pos_x;
    wire [9:0] stored_rnd_pos_y;
    
    FDRE #(.INIT(1'b0)) stored_rnd_x_reg[9:0] (
        .C({10{clk}}),
        .R({10{reset}}),
        .CE({10{btnD_edge}}),
        .D(rnd_pos_x),
        .Q(stored_rnd_pos_x)
    );
    
    FDRE #(.INIT(1'b0)) stored_rnd_y_reg[9:0] (
        .C({10{clk}}),
        .R({10{reset}}),
        .CE({10{btnD_edge}}),
        .D(rnd_pos_y),
        .Q(stored_rnd_pos_y)
    );

    wire [9:0] init_pos_x;
    wire [9:0] pos_x_din;
    wire pos_x_load;
    
    assign init_pos_x = 10'd200 & ~{10{btnD_state}} | (({10{(stored_rnd_pos_x == 10'd0)}} & 10'd40 | 
                                           {10{(stored_rnd_pos_x == 10'd1)}} & 10'd520 | 
                                           {10{(stored_rnd_pos_x == 10'd2)}} & 10'd280 | 
                                           {10{(stored_rnd_pos_x == 10'd3)}} & 10'd600 | 
                                           {10{(stored_rnd_pos_x == 10'd4)}} & 10'd120 | 
                                           {10{(stored_rnd_pos_x == 10'd5)}} & 10'd360 | 
                                           {10{(stored_rnd_pos_x == 10'd6)}} & 10'd200 | 
                                           {10{(stored_rnd_pos_x == 10'd7)}} & 10'd440) & {10{btnD_state}} & {10{freeze}});

    assign pos_x_din = ({10{~load_init_pos}} & next_pos_x) | ({10{load_init_pos}} & init_pos_x);
    assign pos_x_load = frame;
    
    wire [14:0] pos_xq;
    
    countUD15L pos_x_counter(
        .clk(clk),
        .Up(1'b0),
        .Dw(1'b0),
        .LD(pos_x_load),
        .Din({5'b00000, pos_x_din}),
        .Q(pos_xq),
        .UTC(),
        .DTC()
    );
    
    assign pos_x = pos_xq[9:0];

    wire [9:0] init_pos_y;
    wire [9:0] pos_y_din;
    wire pos_y_load;
    
    assign init_pos_y = 10'd150 & ~{10{btnD_state}} | (({10{(stored_rnd_pos_y == 10'd0)}} & 10'd280 | 
                                           {10{(stored_rnd_pos_y == 10'd1)}} & 10'd40 | 
                                           {10{(stored_rnd_pos_y == 10'd2)}} & 10'd400 | 
                                           {10{(stored_rnd_pos_y == 10'd3)}} & 10'd160 | 
                                           {10{(stored_rnd_pos_y == 10'd4)}} & 10'd340 | 
                                           {10{(stored_rnd_pos_y == 10'd5)}} & 10'd100 | 
                                           {10{(stored_rnd_pos_y == 10'd6)}} & 10'd450 | 
                                           {10{(stored_rnd_pos_y == 10'd7)}} & 10'd220) & {10{btnD_state}} & {10{freeze}});

    assign pos_y_din = ({10{~load_init_pos}} & next_pos_y) | ({10{load_init_pos}} & init_pos_y);
    assign pos_y_load = frame;
    
    wire [14:0] pos_yq;
    
    countUD15L pos_y_counter(
        .clk(clk),
        .Up(1'b0),
        .Dw(1'b0),
        .LD(pos_y_load),
        .Din({5'b00000, pos_y_din}), 
        .Q(pos_yq),     
        .UTC(),
        .DTC()
    );

    assign pos_y = pos_yq[9:0];

    FDRE #(.INIT(1'b0)) v_x_reg0 (.C(clk), .R(reset), .CE(frame), .D(next_v_x[0]), .Q(v_x[0]));
    FDRE #(.INIT(1'b0)) v_x_reg_bus[8:1] (
        .C({8{clk}}), .R({8{reset}}), .CE({8{frame}}),
        .D(next_v_x[8:1]), .Q(v_x[8:1])
    );
    FDRE #(.INIT(1'b0)) v_x_reg9 (.C(clk), .R(reset), .CE(frame), .D(next_v_x[9]), .Q(v_x[9]));

    FDRE #(.INIT(1'b1)) v_y_reg0 (.C(clk), .R(reset), .CE(frame), .D(next_v_y[0]), .Q(v_y[0]));
    FDRE #(.INIT(1'b0)) v_y_reg_bus[8:1] (
        .C({8{clk}}), .R({8{reset}}), .CE({8{frame}}),
        .D(next_v_y[8:1]), .Q(v_y[8:1])
    );
    FDRE #(.INIT(1'b0)) v_y_reg9 (.C(clk), .R(reset), .CE(frame), .D(next_v_y[9]), .Q(v_y[9]));

endmodule 
