module haze_removal_top#(
        parameter Y_ENHANCE_ENABLE = 1          ,
        parameter PIC_WIDTH        = 640
)(
        input           clk                     ,
        input           rst_n                   ,  
        //处理前数据    
        input           pre_frame_vsync         , 
        input           pre_frame_href          ,  
        input           pre_frame_clken         , 
        input   [23:0]  pre_img                 ,       
        //处理后的数据
        output          post_frame_vsync        , 
        output          post_frame_href         ,  
        output          post_frame_clken        , 
        output  [23:0]  post_img                
);

wire                 dark_channel_frame_vsync    ;
wire                 dark_channel_frame_href     ; 
wire                 dark_channel_frame_clken    ;
wire    [7  : 0]     dark_channel_img            ; 
     
wire                 src_cal_A_frame_vsync       ;
wire                 src_cal_A_frame_href        ; 
wire                 src_cal_A_frame_clken       ;
wire    [7  : 0]     src_cal_A_result            ; 
wire                 src_cal_A_valid             ; 
     
wire                 src_tx_frame_vsync          ;
wire                 src_tx_frame_href           ; 
wire                 src_tx_frame_clken          ;
wire    [7  : 0]     src_tx_img                  ; 
     
wire                 cal_src_frame_vsync         ;
wire                 cal_src_frame_href          ;
wire                 cal_src_frame_clken         ;
wire    [23 : 0]     cal_img                     ;
wire                 cal_tx_frame_vsync          ;
wire                 cal_tx_frame_href           ;
wire                 cal_tx_frame_clken          ;
wire    [7  : 0]     cal_tx_img                  ;
wire    [7  : 0]     cal_A                       ;

dark_channel#(
        .PIC_WIDTH              (PIC_WIDTH                      )
)u_dark_channel(
        .clk                    (clk                            ),
        .rst_n                  (rst_n                          ),  
        //处理前数据
        .pre_frame_vsync        (pre_frame_vsync                ), 
        .pre_frame_href         (pre_frame_href                 ),  
        .pre_frame_clken        (pre_frame_clken                ), 
        .pre_img                (pre_img                        ),
        //处理后的数据
        .post_frame_vsync       (dark_channel_frame_vsync       ), 
        .post_frame_href        (dark_channel_frame_href        ),  
        .post_frame_clken       (dark_channel_frame_clken       ), 
        .post_img               (dark_channel_img               )
);

calculate_A u_calculate_A(
        .clk                    (clk                            ),
        .rst_n                  (rst_n                          ),  
        //处理前数据    
        .pre_frame_vsync        (pre_frame_vsync                ), 
        .pre_frame_href         (pre_frame_href                 ),  
        .pre_frame_clken        (pre_frame_clken                ), 
        .pre_img                (pre_img                        ),       
        //处理后的数据  
        .post_frame_vsync       (src_cal_A_frame_vsync          ), 
        .post_frame_href        (src_cal_A_frame_href           ),  
        .post_frame_clken       (src_cal_A_frame_clken          ),
        .post_result            (src_cal_A_result               ), 
        .post_done              (src_cal_A_valid                )
);

tx_get u_tx_get(
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ), 
        //处理前数据    
        .pre_frame_vsync        (dark_channel_frame_vsync   ),
        .pre_frame_href         (dark_channel_frame_href    ), 
        .pre_frame_clken        (dark_channel_frame_clken   ),
        .pre_img                (dark_channel_img           ),
        .A_value                (src_cal_A_result           ),
        //处理后的数据  
        .post_frame_vsync       (src_tx_frame_vsync         ),
        .post_frame_href        (src_tx_frame_href          ),
        .post_frame_clken       (src_tx_frame_clken         ),
        .post_img               (src_tx_img                 )
);

time_alignment u_time_alignment(
        .clk                     (clk                       ),
        .rst_n                   (rst_n                     ),  
        //处理前数据
        .pre_src_frame_vsync     (pre_frame_vsync           ), 
        .pre_src_frame_href      (pre_frame_href            ),  
        .pre_src_frame_clken     (pre_frame_clken           ), 
        .pre_img                 (pre_img                   ),

        .pre_tx_frame_vsync      (src_tx_frame_vsync        ),
        .pre_tx_frame_href       (src_tx_frame_href         ),
        .pre_tx_frame_clken      (src_tx_frame_clken        ),
        .pre_tx_img              (src_tx_img                ),

        .pre_A                   (src_cal_A_result          ),
        //处理后的数据()
        .post_src_frame_vsync    (cal_src_frame_vsync       ), 
        .post_src_frame_href     (cal_src_frame_href        ),  
        .post_src_frame_clken    (cal_src_frame_clken       ), 
        .post_img                (cal_img                   ),

        .post_tx_frame_vsync     (cal_tx_frame_vsync        ),
        .post_tx_frame_href      (cal_tx_frame_href         ),
        .post_tx_frame_clken     (cal_tx_frame_clken        ),
        .post_tx_img             (cal_tx_img                ),

        .post_A                  (cal_A                     ) 
);

generate 
if(Y_ENHANCE_ENABLE == 0) begin
        haze_remove_cal u_haze_remove_cal(
                .clk                     (clk                       ),
                .rst_n                   (rst_n                     ),  

                .pre_src_frame_vsync     (cal_src_frame_vsync       ), 
                .pre_src_frame_href      (cal_src_frame_href        ),  
                .pre_src_frame_clken     (cal_src_frame_clken       ), 
                .pre_img                 (cal_img                   ),

                .pre_tx_frame_vsync      (cal_tx_frame_vsync        ),
                .pre_tx_frame_href       (cal_tx_frame_href         ),
                .pre_tx_frame_clken      (cal_tx_frame_clken        ),
                .pre_tx_img              (cal_tx_img                ),

                .pre_A                   (cal_A                     ),

                .post_frame_vsync        (post_frame_vsync          ), 
                .post_frame_href         (post_frame_href           ),  
                .post_frame_clken        (post_frame_clken          ), 
                .post_img                (post_img                  )
        );
end
else begin


        wire                 haze_removal_vsync         ;
        wire                 haze_removal_hsync         ;
        wire                 haze_removal_de            ;
        wire    [23 : 0]     haze_removal_data          ;
        wire                 tem_YCbCr_vsync            ;
        wire                 tem_YCbCr_hsync            ;
        wire                 tem_YCbCr_de               ;
        wire    [07 : 0]     tem_Y_data                 ;
        wire    [07 : 0]     tem_Cb_data                ;
        wire    [07 : 0]     tem_Cr_data                ;

        haze_remove_cal u_haze_remove_cal(
                .clk                     (clk                           ),
                .rst_n                   (rst_n                         ),  

                .pre_src_frame_vsync     (cal_src_frame_vsync           ), 
                .pre_src_frame_href      (cal_src_frame_href            ),  
                .pre_src_frame_clken     (cal_src_frame_clken           ), 
                .pre_img                 (cal_img                       ),

                .pre_tx_frame_vsync      (cal_tx_frame_vsync            ),
                .pre_tx_frame_href       (cal_tx_frame_href             ),
                .pre_tx_frame_clken      (cal_tx_frame_clken            ),
                .pre_tx_img              (cal_tx_img                    ),

                .pre_A                   (cal_A                         ),

                .post_frame_vsync        (haze_removal_vsync            ), 
                .post_frame_href         (haze_removal_hsync            ),  
                .post_frame_clken        (haze_removal_de               ), 
                .post_img                (haze_removal_data             )
        );

        VIP_RGB888_YCbCr444 u_rgb_ycncr_haze(
                //global clock
                .clk                    (clk                            ),
                .rst_n                  (rst_n                          ),

                //Image data prepred to be processd
                .pre_frame_vsync        (haze_removal_vsync             ),
                .pre_frame_href         (haze_removal_hsync             ),
                .pre_frame_clken        (haze_removal_de                ),
                .pre_img_red            (haze_removal_data[16+:8]       ),
                .pre_img_green          (haze_removal_data[ 8+:8]       ),
                .pre_img_blue           (haze_removal_data[ 0+:8]       ),
                
                //Image data has been processd
                .post_frame_vsync       (tem_YCbCr_vsync                ),
                .post_frame_href        (tem_YCbCr_hsync                ),
                .post_frame_clken       (tem_YCbCr_de                   ),
                .post_img_Y             (tem_Y_data                     ),
                .post_img_Cb            (tem_Cb_data                    ),
                .post_img_Cr            (tem_Cr_data                    )
        ); 

        YCbCr2RGB u_ycbcr_to_rgb(
                .i_sys_clk              (clk                            ),

                .i_vs                   (tem_YCbCr_vsync                ),
                .i_hs                   (tem_YCbCr_hsync                ),
                .i_convert_en           (tem_YCbCr_de                   ),
                .i_y_data               (tem_Y_data + 30                ),
                .i_cr_data              (tem_Cb_data                    ),
                .i_cb_data              (tem_Cr_data                    ),

                .o_vs                   (post_frame_vsync               ),
                .o_hs                   (post_frame_href                ),
                .o_convert_en           (post_frame_clken               ),  
                .o_red                  (post_img[ 0+:8]                ),
                .o_green                (post_img[ 8+:8]                ),
                .o_blue                 (post_img[16+:8]                )
        );
end     
endgenerate


endmodule
