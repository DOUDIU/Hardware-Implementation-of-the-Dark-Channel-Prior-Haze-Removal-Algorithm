module haze_remove_top(
    input           clk                 ,
    input           rst_n               ,  
    //处理前数据
    input           pre_frame_vsync     , 
    input           pre_frame_href      ,  
    input           pre_frame_clken     , 
    input   [23:0]  pre_img,       
    //处理后的数据
    output          post_frame_vsync    , 
    output          post_frame_href     ,  
    output          post_frame_clken    , 
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

dark_channel u_dark_channel(
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),  
        //处理前数据        
        .pre_frame_vsync        (pre_frame_vsync            ), 
        .pre_frame_href         (pre_frame_href             ),  
        .pre_frame_clken        (pre_frame_clken            ), 
        .pre_img                (pre_img                    ),
        //处理后的数据      
        .post_frame_vsync       (dark_channel_frame_vsync   ), 
        .post_frame_href        (dark_channel_frame_href    ),  
        .post_frame_clken       (dark_channel_frame_clken   ), 
        .post_img               (dark_channel_img           )
    );    

calculate_A u_calculate_A(
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),  
        //处理前数据    
        .pre_frame_vsync        (pre_frame_vsync            ), 
        .pre_frame_href         (pre_frame_href             ),  
        .pre_frame_clken        (pre_frame_clken            ), 
        .pre_img                (pre_img                    ),       
        //处理后的数据  
        .post_frame_vsync       (src_cal_A_frame_vsync      ), 
        .post_frame_href        (src_cal_A_frame_href       ),  
        .post_frame_clken       (src_cal_A_frame_clken      ),
        .post_result            (src_cal_A_result           ), 
        .post_done              (src_cal_A_valid            )
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

// VIP_RGB888_YCbCr444	u_rgb_ycncr_haze(
// 	//global clock
// 	.clk				(clk					),					
// 	.rst_n				(rst_n					),				

// 	//Image data prepred to be processd
// 	.per_frame_vsync	(haze_remove_vsync		),		
// 	.per_frame_href		(haze_remove_hsync		),		
// 	.per_frame_clken	(haze_remove_de   		),		
// 	.per_img_red		(img_haze_remove[23:16]	),			
// 	.per_img_green		(img_haze_remove[15: 8]	),		
// 	.per_img_blue		(img_haze_remove[7 : 0]	),			
	
// 	//Image data has been processd
// 	.post_frame_vsync	(post1_frame_vsync		),	
// 	.post_frame_href	(post1_frame_href 		),		
// 	.post_frame_clken	(post1_frame_clken		),	
// 	.post_img_Y			(post1_img_Y     		),			
// 	.post_img_Cb		(post1_img_Cr    		),			
// 	.post_img_Cr		(post1_img_Cb    		)			
// ); 

// YCbCr2RGB	u_ycbcr_to_rgb(
// 	.i_sys_clk			(clk					),

// 	.i_vs				(post1_frame_vsync		),
// 	.i_hs				(post1_frame_href 		),
// 	.i_convert_en		(post1_frame_clken		),
// 	.i_y_data 			(post1_img_Y + 30		),
// 	.i_cr_data			(post1_img_Cr			),
// 	.i_cb_data			(post1_img_Cb			),

// 	.o_vs				(post2_frame_vsync		), 
// 	.o_hs				(post2_frame_href 		),                                                                                                   
// 	.o_convert_en		(post2_frame_clken		),  
// 	.o_red  			(post2_img_r      		),
// 	.o_green			(post2_img_g      		),
// 	.o_blue				(post2_img_b      		)                                                               
// );

endmodule
