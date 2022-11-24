module image_gaussian_filter
(
	input   wire				clk,
	input   wire				rst_n,

	input	wire				per_frame_vsync ,
	input	wire				per_frame_href  ,	
	input	wire				per_frame_clken ,
	input	wire [7:0]			per_img_gray    ,	
	
	output	wire 				post_frame_vsync,	
	output	wire 				post_frame_href,	
	output	wire 				post_frame_clken,		
	output  wire [7:0]			post_img_gray
);

wire    matrix_generator_vsync  ;
wire    matrix_generator_href   ;
wire    matrix_generator_clken  ;

reg     matrix_generator_vsync_d1  ;
reg     matrix_generator_href_d1   ;
reg     matrix_generator_clken_d1  ;

reg     matrix_generator_vsync_d2  ;
reg     matrix_generator_href_d2   ;
reg     matrix_generator_clken_d2  ;

reg     [11 : 0]    sum_gray1;
reg     [11 : 0]    sum_gray2;
reg     [11 : 0]    sum_gray3;
reg     [11 : 0]    sum_gray;

wire    [7  : 0]	gray_temp_11;
wire    [7  : 0]	gray_temp_12;
wire    [7  : 0]	gray_temp_13;
wire    [7  : 0]	gray_temp_21;
wire    [7  : 0]	gray_temp_22;
wire    [7  : 0]	gray_temp_23;
wire    [7  : 0]	gray_temp_31;
wire    [7  : 0]	gray_temp_32;
wire    [7  : 0]	gray_temp_33;

matrix_generate_3x3 #(
	.DATA_WIDTH(8),
	.DATA_DEPTH(640)
	)u_matrix_generate_3x3(
    .clk        (clk), 
    .rst_n      (rst_n),
    
    //处理前图像数据
    .per_frame_vsync    (per_frame_vsync),
    .per_frame_href     (per_frame_href ), 
    .per_frame_clken    (per_frame_clken),
    .per_img_y          (per_img_gray   ),
    
    //处理后的图像数据
    .matrix_frame_vsync (matrix_generator_vsync),
    .matrix_frame_href  (matrix_generator_href ),
    .matrix_frame_clken (matrix_generator_clken),
    .matrix_p11         (gray_temp_11   ),    
    .matrix_p12         (gray_temp_12   ),    
    .matrix_p13         (gray_temp_13   ),
    .matrix_p21         (gray_temp_21   ),    
    .matrix_p22         (gray_temp_22   ),    
    .matrix_p23         (gray_temp_23   ),
    .matrix_p31         (gray_temp_31   ),    
    .matrix_p32         (gray_temp_32   ),    
    .matrix_p33         (gray_temp_33   )
);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        sum_gray1   <=  0;
        sum_gray2   <=  0;
        sum_gray3   <=  0;
    end
    else begin
        sum_gray1   <=  (gray_temp_11     )   + (gray_temp_12 << 1)    +   (gray_temp_13     )   ;
        sum_gray2   <=  (gray_temp_21 << 1)   + (gray_temp_22 << 2)    +   (gray_temp_23 << 1)   ;
        sum_gray3   <=  (gray_temp_31     )   + (gray_temp_32 << 1)    +   (gray_temp_33     )   ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        sum_gray    <=  0;
    end
    else begin
        sum_gray    <=  sum_gray1 + sum_gray2 + sum_gray3;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        matrix_generator_vsync_d1   <=  0;
        matrix_generator_href_d1    <=  0;
        matrix_generator_clken_d1   <=  0;

        matrix_generator_vsync_d2   <=  0;
        matrix_generator_href_d2    <=  0;
        matrix_generator_clken_d2   <=  0;
    end
    else begin
        matrix_generator_vsync_d1   <=  matrix_generator_vsync;
        matrix_generator_href_d1    <=  matrix_generator_href ;
        matrix_generator_clken_d1   <=  matrix_generator_clken;
        
        matrix_generator_vsync_d2   <=  matrix_generator_vsync_d1;
        matrix_generator_href_d2    <=  matrix_generator_href_d1 ;
        matrix_generator_clken_d2   <=  matrix_generator_clken_d1;
    end
end

assign  post_frame_vsync    =   matrix_generator_vsync_d2;
assign  post_frame_href     =   matrix_generator_href_d2 ;
assign  post_frame_clken    =   matrix_generator_clken_d2;
assign  post_img_gray       =   sum_gray >> 4;

endmodule