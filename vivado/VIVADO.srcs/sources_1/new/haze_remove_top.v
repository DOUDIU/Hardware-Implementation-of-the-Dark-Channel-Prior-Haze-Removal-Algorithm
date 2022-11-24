module haze_remove_top(
        input           clk                 ,
        input           rst_n               ,  
        //处理前数据
        input           per_frame_vsync     , 
        input           per_frame_href      ,  
        input           per_frame_clken     , 
        input   [23:0]  per_img,       
        //处理后的数据
        output          post_frame_vsync    , 
        output          post_frame_href     ,  
        output          post_frame_clken    , 
        output  [7 :0]  post_img  
    );

wire            dark_channel_frame_vsync    ;
wire            dark_channel_frame_href     ; 
wire            dark_channel_frame_clken    ;
wire    [7 :0]  dark_channel_img            ; 




dark_channel u_dark_channel(
        .clk                (clk                        ),
        .rst_n              (rst_n                      ),  
        //处理前数据
        .per_frame_vsync    (per_frame_vsync            ), 
        .per_frame_href     (per_frame_href             ),  
        .per_frame_clken    (per_frame_clken            ), 
        .per_img            (per_img                    ),
        //处理后的数据
        .post_frame_vsync   (dark_channel_frame_vsync   ), 
        .post_frame_href    (dark_channel_frame_href    ),  
        .post_frame_clken   (dark_channel_frame_clken   ), 
        .post_img           (dark_channel_img           )
    );    


assign  post_frame_vsync    =   dark_channel_frame_vsync;
assign  post_frame_href     =   dark_channel_frame_href ;
assign  post_frame_clken    =   dark_channel_frame_clken;
assign  post_img            =   dark_channel_img        ;


endmodule
