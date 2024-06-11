module search_block_min#(
    parameter       PIC_WIDTH  =   640   
)(
    input           clk                 ,
    input           rst_n               ,  
    //处理前数据
    input           pre_frame_vsync     , 
    input           pre_frame_href      ,  
    input           pre_frame_clken     , 
    input   [23:0]  pre_img             ,       
    //处理后的数据
    output          post_frame_vsync    , 
    output          post_frame_href     ,  
    output          post_frame_clken    , 
    output  [7 :0]  post_img            
);


reg                     post_frame_vsync_d1 ;
reg                     post_frame_href_d1  ;
reg                     post_frame_clken_d1 ;
reg                     post_frame_vsync_d2 ;
reg                     post_frame_href_d2  ;
reg                     post_frame_clken_d2 ;



wire                    matrix_frame_vsync  ;
wire                    matrix_frame_href   ;
wire                    matrix_frame_clken  ;

wire        [7 : 0]     matrix_p11          ;
wire        [7 : 0]     matrix_p12          ;
wire        [7 : 0]     matrix_p13          ;
wire        [7 : 0]     matrix_p21          ;
wire        [7 : 0]     matrix_p22          ;
wire        [7 : 0]     matrix_p23          ;
wire        [7 : 0]     matrix_p31          ;
wire        [7 : 0]     matrix_p32          ;
wire        [7 : 0]     matrix_p33          ;

wire        [7 : 0]     max_data            ;
wire        [7 : 0]     mid_data            ;
wire        [7 : 0]     min_data            ;
wire        [7 : 0]     max_data_0          ;
wire        [7 : 0]     mid_data_0          ;
wire        [7 : 0]     min_data_0          ;
wire        [7 : 0]     max_data_1          ;
wire        [7 : 0]     mid_data_1          ;
wire        [7 : 0]     min_data_1          ;
wire        [7 : 0]     max_data_2          ;
wire        [7 : 0]     mid_data_2          ;
wire        [7 : 0]     min_data_2          ;


matrix_generate_3x3 #(
    .DATA_WIDTH             (8                      ),
    .DATA_DEPTH             (PIC_WIDTH              )
)u_matrix_generate_3x3(
    .clk                    (clk                    ),  
    .rst_n                  (rst_n                  ),

    .pre_frame_vsync        (pre_frame_vsync        ),
    .pre_frame_href         (pre_frame_href         ),
    .pre_frame_clken        (pre_frame_clken        ),
    .pre_img_y              (pre_img                ),
    
    .matrix_frame_vsync     (matrix_frame_vsync     ),
    .matrix_frame_href      (matrix_frame_href      ),
    .matrix_frame_clken     (matrix_frame_clken     ),
    .matrix_p11             (matrix_p11             ),
    .matrix_p12             (matrix_p12             ), 
    .matrix_p13             (matrix_p13             ),
    .matrix_p21             (matrix_p21             ), 
    .matrix_p22             (matrix_p22             ), 
    .matrix_p23             (matrix_p23             ),
    .matrix_p31             (matrix_p31             ), 
    .matrix_p32             (matrix_p32             ), 
    .matrix_p33             (matrix_p33             )
);


sort3 u_sort3_0(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .data1      (matrix_p11     ), 
    .data2      (matrix_p12     ), 
    .data3      (matrix_p13     ),
    
    .max_data   (max_data_0     ), 
    .mid_data   (mid_data_0     ), 
    .min_data   (min_data_0     )
);

sort3 u_sort3_1(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .data1      (matrix_p21     ), 
    .data2      (matrix_p22     ), 
    .data3      (matrix_p23     ),
    
    .max_data   (max_data_1     ), 
    .mid_data   (mid_data_1     ), 
    .min_data   (min_data_1     )
);

sort3 u_sort3_2(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .data1      (matrix_p31     ), 
    .data2      (matrix_p32     ), 
    .data3      (matrix_p33     ),
    
    .max_data   (max_data_2     ), 
    .mid_data   (mid_data_2     ), 
    .min_data   (min_data_2     )
);


sort3 u_sort3_3(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .data1      (min_data_0     ), 
    .data2      (min_data_1     ), 
    .data3      (min_data_2     ),
    
    .max_data   (max_data       ), 
    .mid_data   (mid_data       ), 
    .min_data   (min_data       )
);

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        post_frame_vsync_d1     <=      0                   ;
        post_frame_href_d1      <=      0                   ;
        post_frame_clken_d1     <=      0                   ;
        post_frame_vsync_d2     <=      0                   ;
        post_frame_href_d2      <=      0                   ;
        post_frame_clken_d2     <=      0                   ;
    end
    else begin
        post_frame_vsync_d1     <=      matrix_frame_vsync  ;
        post_frame_href_d1      <=      matrix_frame_href   ;
        post_frame_clken_d1     <=      matrix_frame_clken  ;
        post_frame_vsync_d2     <=      post_frame_vsync_d1 ;
        post_frame_href_d2      <=      post_frame_href_d1  ;
        post_frame_clken_d2     <=      post_frame_clken_d1 ;
    end
end



assign      post_frame_vsync    =       post_frame_vsync_d2 ;
assign      post_frame_href     =       post_frame_href_d2  ;
assign      post_frame_clken    =       post_frame_clken_d2 ;
assign      post_img            =       min_data            ;

endmodule
