module RGB(
    input clk,
    input frame,
    input reset,
    input btnU,
    input btnL, 
    input btnR,
    input btnD,
    input [15:0] sw,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output [7:0] timer_output,
    output [7:0] led,
    output half_sec,
    output an_flash,
    output [4:0] state
    );

    // Define active region
    wire h_active, v_active;
    wire active;
    
    assign h_active = (h_cnt < 10'd640);
    assign v_active = (v_cnt < 10'd480);
    assign active = h_active & v_active;

    // Define border region
    wire border_left, border_right, border_top, border_bottom;
    wire is_border;
    
    assign border_left = (h_cnt < 10'd8);
    assign border_right = (h_cnt >= 10'd632) & (h_cnt < 10'd640);
    assign border_top = (v_cnt < 10'd8);
    assign border_bottom = (v_cnt >= 10'd472) & (v_cnt < 10'd480);
    assign is_border = border_left | border_right | border_top | border_bottom;

    // Define membrane region
    wire membrane_region;

    assign membrane_region = (h_cnt >= 10'd315) & (h_cnt < 10'd322) & ~border_top & ~border_bottom;

    // Define membrane signals
    wire magenta_membrane;
    wire red_membrane;
    wire blue_membrane;
    wire no_membrane;

    wire valid_btn;

    assign valid_btn = ~(state[3] | state[4]);
    assign magenta_membrane = (~btnL & ~btnR & valid_btn) | ~valid_btn;
    assign red_membrane = btnL & ~btnR & valid_btn;
    assign blue_membrane = ~btnL & btnR & valid_btn;
    assign no_membrane = btnL & btnR & valid_btn;

    wire is_molecule_r1, is_molecule_r2, is_molecule_r3, is_molecule_r4;
    wire is_molecule_b1, is_molecule_b2, is_molecule_b3, is_molecule_b4;
    wire is_red_r1, is_red_r2, is_red_r3, is_red_r4;
    wire is_red_b1, is_red_b2, is_red_b3, is_red_b4;

    wire [9:0] pos_x_r1, pos_y_r1;
    wire [9:0] pos_x_r2, pos_y_r2;
    wire [9:0] pos_x_r3, pos_y_r3;
    wire [9:0] pos_x_r4, pos_y_r4;
    wire [9:0] pos_x_b1, pos_y_b1;
    wire [9:0] pos_x_b2, pos_y_b2;
    wire [9:0] pos_x_b3, pos_y_b3;
    wire [9:0] pos_x_b4, pos_y_b4;

    // Define when molecules are separated for game control state machine
    wire separated;

    assign separated = (((pos_x_r1 < 10'd315) & (pos_x_r2 < 10'd315) & (pos_x_r3 < 10'd315) & (pos_x_r4 < 10'd315)) & 
                       ((pos_x_b1 >= 10'd322) & (pos_x_b2 >= 10'd322) & (pos_x_b3 >= 10'd322) & (pos_x_b4 >= 10'd322))) | 
                       (((pos_x_b1 < 10'd315) & (pos_x_b2 < 10'd315) & (pos_x_b3 < 10'd315) & (pos_x_b4 < 10'd315)) & 
                       ((pos_x_r1 >= 10'd322) & (pos_x_r2 >= 10'd322) & (pos_x_r3 >= 10'd322) & (pos_x_r4 >= 10'd322)));

    molecule_r1 molr1(.clk(clk), .frame(frame), .reset(reset), .h_cnt(h_cnt), .v_cnt(v_cnt), .magenta_membrane(magenta_membrane), .red_membrane(red_membrane), .blue_membrane(blue_membrane), .no_membrane(no_membrane), .membrane_on(membrane_on), .freeze(freeze), .btnD(btnD), .is_red(is_red_r1), .is_molecule(is_molecule_r1), .pos_x_r1(pos_x_r1), .pos_y_r1(pos_y_r1));
    molecule_r2 molr2(.clk(clk), .frame(frame), .reset(reset), .h_cnt(h_cnt), .v_cnt(v_cnt), .magenta_membrane(magenta_membrane), .red_membrane(red_membrane), .blue_membrane(blue_membrane), .no_membrane(no_membrane), .membrane_on(membrane_on), .freeze(freeze), .btnD(btnD), .is_red(is_red_r2), .is_molecule(is_molecule_r2), .pos_x_r2(pos_x_r2), .pos_y_r2(pos_y_r2));
    molecule_r3 molr3(.clk(clk), .frame(frame), .reset(reset), .h_cnt(h_cnt), .v_cnt(v_cnt), .magenta_membrane(magenta_membrane), .red_membrane(red_membrane), .blue_membrane(blue_membrane), .no_membrane(no_membrane), .membrane_on(membrane_on), .freeze(freeze), .btnD(btnD), .is_red(is_red_r3), .is_molecule(is_molecule_r3), .pos_x_r3(pos_x_r3), .pos_y_r3(pos_y_r3));
    molecule_r4 molr4(.clk(clk), .frame(frame), .reset(reset), .h_cnt(h_cnt), .v_cnt(v_cnt), .magenta_membrane(magenta_membrane), .red_membrane(red_membrane), .blue_membrane(blue_membrane), .no_membrane(no_membrane), .membrane_on(membrane_on), .freeze(freeze), .btnD(btnD), .is_red(is_red_r4), .is_molecule(is_molecule_r4), .pos_x_r4(pos_x_r4), .pos_y_r4(pos_y_r4));
    molecule_b1 molb1(.clk(clk), .frame(frame), .reset(reset), .h_cnt(h_cnt), .v_cnt(v_cnt), .magenta_membrane(magenta_membrane), .red_membrane(red_membrane), .blue_membrane(blue_membrane), .no_membrane(no_membrane), .membrane_on(membrane_on), .freeze(freeze), .btnD(btnD), .is_red(is_red_b1), .is_molecule(is_molecule_b1), .pos_x_b1(pos_x_b1), .pos_y_b1(pos_y_b1));
    molecule_b2 molb2(.clk(clk), .frame(frame), .reset(reset), .h_cnt(h_cnt), .v_cnt(v_cnt), .magenta_membrane(magenta_membrane), .red_membrane(red_membrane), .blue_membrane(blue_membrane), .no_membrane(no_membrane), .membrane_on(membrane_on), .freeze(freeze), .btnD(btnD), .is_red(is_red_b2), .is_molecule(is_molecule_b2), .pos_x_b2(pos_x_b2), .pos_y_b2(pos_y_b2));
    molecule_b3 molb3(.clk(clk), .frame(frame), .reset(reset), .h_cnt(h_cnt), .v_cnt(v_cnt), .magenta_membrane(magenta_membrane), .red_membrane(red_membrane), .blue_membrane(blue_membrane), .no_membrane(no_membrane), .membrane_on(membrane_on), .freeze(freeze), .btnD(btnD), .is_red(is_red_b3), .is_molecule(is_molecule_b3), .pos_x_b3(pos_x_b3), .pos_y_b3(pos_y_b3));
    molecule_b4 molb4(.clk(clk), .frame(frame), .reset(reset), .h_cnt(h_cnt), .v_cnt(v_cnt), .magenta_membrane(magenta_membrane), .red_membrane(red_membrane), .blue_membrane(blue_membrane), .no_membrane(no_membrane), .membrane_on(membrane_on), .freeze(freeze), .btnD(btnD), .is_red(is_red_b4), .is_molecule(is_molecule_b4), .pos_x_b4(pos_x_b4), .pos_y_b4(pos_y_b4));

    wire is_molecule = is_molecule_r1 | is_molecule_r2 | is_molecule_r3 | is_molecule_r4 | 
                       is_molecule_b1 | is_molecule_b2 | is_molecule_b3 | is_molecule_b4;

    wire is_red = (is_molecule_r1 & is_red_r1) | (is_molecule_r2 & is_red_r2) | 
                  (is_molecule_r3 & is_red_r3) | (is_molecule_r4 & is_red_r4) |
                  (is_molecule_b1 & is_red_b1) | (is_molecule_b2 & is_red_b2) | 
                  (is_molecule_b3 & is_red_b3) | (is_molecule_b4 & is_red_b4);

    // Half second counter
    wire [5:0] half_sec_frame_count;
    wire half_sec_counter_done;
    
    countUD15L half_sec_frame_counter(.clk(clk), .Up(frame), .Dw(1'b0), .LD(half_sec_counter_done), .Din(15'd0), .Q(half_sec_frame_count), .UTC(), .DTC());
    
    assign half_sec_counter_done = (half_sec_frame_count == 10'd30);
    
    FDRE #(.INIT(1'b0)) half_sec_signal (
        .C(clk), .R(reset), .CE(half_sec_counter_done),
        .D(~half_sec), .Q(half_sec)
    );
    
    wire DTC;
    
    // Second counter
    wire [5:0] frame_count;
    wire sec_counter_done;
    wire sec;
    
    countUD15L sec_frame_counter(.clk(clk), .Up(frame), .Dw(1'b0), .LD(sec_counter_done), .Din(15'd0), .Q(frame_count), .UTC(), .DTC());
    
    assign sec_counter_done = (frame_count == 10'd60);
    
    FDRE #(.INIT(1'b0)) sec_signal (
        .C(clk), .R(reset), .CE(sec_counter_done),
        .D(~sec), .Q(sec)
    );

    // 8 second timer
    wire [5:0] sec_count;
    countUD15L flash_timer_counter(.clk(clk), .Up(sec_counter_done), .Dw(1'b0), .LD(LD), .Din(15'd0), .Q(sec_count), .UTC(), .DTC());
    
    assign FlashTimeUp = (sec_count == 10'd8);
    
    // Game timer
    countUD15L counter(
        .clk(clk),
        .Up(1'b0),
        .Dw(sec_counter_done & state[2] & ~DTC),
        .LD(LD),
        .Din(sw[15:8]),
        .Q(timer_output),
        .UTC(),
        .DTC(DTC)
    );

    // Game control state machine
    wire freeze, FlashTimeUp, TimeUp, LD, membrane_on;
    wire [4:0] state;

    game_control control(
        .clk(clk),
        .reset(reset),
        .btnU(btnU),
        .FlashTimeUp(FlashTimeUp),
        .TimeUp(DTC),
        .separated(separated),
        .freeze(freeze),
        .flash(flash),
        .LD(LD),
        .membrane_on(membrane_on),
        .an_flash(an_flash),
        .state(state)
    );
    
    assign flashing = flash & half_sec & ~FlashTimeUp;
    
    assign vgaRed = {4{active & is_molecule & ~is_border & is_red | (active & membrane_region & magenta_membrane & ~no_membrane | active & membrane_region & red_membrane & ~no_membrane) & membrane_on}};
    assign vgaGreen = {4{active & is_border & ((flash & flashing) | ~flash)}};
    assign vgaBlue = {4{active & is_molecule & ~is_border & ~is_red | (active & membrane_region & magenta_membrane & ~no_membrane | active & membrane_region & blue_membrane & ~no_membrane) & membrane_on}};

    // Debug outputs
    assign led[4:0] = state;  // Current state
    assign led[5] = flash;    // Flash signal
    assign led[6] = flashing; // Flashing signal
    assign led[7] = half_sec; // Half second signal

endmodule
