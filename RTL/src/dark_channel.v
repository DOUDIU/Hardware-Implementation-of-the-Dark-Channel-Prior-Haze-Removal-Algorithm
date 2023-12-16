module dark_channel(
        input           clk,             //cmos 像素时钟
        input           rst_n,  
        //处理前数据
        input           pre_frame_vsync, 
        input           pre_frame_href,  
        input           pre_frame_clken, 
        input   [23:0]  pre_img,       
        //处理后的数据
        output          post_frame_vsync    , 
        output          post_frame_href     ,  
        output          post_frame_clken    , 
        output  [7 :0]  post_img  
);


wire            src_min_frame_vsync         ;
wire            src_min_frame_href          ; 
wire            src_min_frame_clken         ;
wire    [7 :0]  src_min_img                 ; 

wire            src_block_min_frame_vsync   ;
wire            src_block_min_frame_href    ; 
wire            src_block_min_frame_clken   ;
wire    [7 :0]  src_block_min_img           ; 


src_min u_src_min(
        .clk                (clk                        ),              
        .rst_n              (rst_n                      ),    
        //处理前数据
        .pre_frame_vsync    (pre_frame_vsync            ), 
        .pre_frame_href     (pre_frame_href             ),   
        .pre_frame_clken    (pre_frame_clken            ),
        .pre_img            (pre_img                    ),
        //处理后的数据
        .post_frame_vsync   (src_min_frame_vsync        ), 
        .post_frame_href    (src_min_frame_href         ),  
        .post_frame_clken   (src_min_frame_clken        ), 
        .post_img           (src_min_img                )
);

search_block_min u_search_block_min(
        .clk                 (clk                       ),
        .rst_n               (rst_n                     ),  
        //处理前数据
        .pre_frame_vsync     (src_min_frame_vsync       ), 
        .pre_frame_href      (src_min_frame_href        ),  
        .pre_frame_clken     (src_min_frame_clken       ), 
        .pre_img             (src_min_img               ),       
        //处理后的数据
        .post_frame_vsync    (src_block_min_frame_vsync ), 
        .post_frame_href     (src_block_min_frame_href  ),  
        .post_frame_clken    (src_block_min_frame_clken ), 
        .post_img            (src_block_min_img         )
);



assign  post_frame_vsync    =   src_block_min_frame_vsync ;
assign  post_frame_href     =   src_block_min_frame_href  ;
assign  post_frame_clken    =   src_block_min_frame_clken ;
assign  post_img            =   src_block_min_img         ;



endmodule