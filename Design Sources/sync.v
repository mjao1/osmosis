module sync(
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    output Hsync,
    output Vsync
    );

    wire h_sync, v_sync;
    
    assign h_sync = (h_cnt >= 10'd655) && (h_cnt <= 10'd750);

    assign v_sync = (v_cnt >= 10'd489) && (v_cnt <= 10'd490);

    assign Hsync = ~h_sync;
    assign Vsync = ~v_sync;
    
endmodule
