module canny_edge_detect_top(
        input       clk,             //cmos 像素时钟
        input       rst_n,  
        //处理前数据
        input       per_frame_vsync, 
        input       per_frame_href,  
        input       per_frame_clken, 
        input [7:0] per_img_y,       
        //处理后的数据
        output      post_frame_vsync    , 
        output      post_frame_href     ,  
        output      post_frame_clken    , 
        output      post_img_bit    
    );
    
wire    [15:0]  gra_path;    
wire            grandient_hs;
wire            grandient_vs;
wire            grandient_de;

wire            nonLocalMax_hs;
wire            nonLocalMax_vs;
wire            nonLocalMax_de;

wire    [1:0]   mx_g;

canny_get_grandient u_canny_get_grandient
(
	.clk           (clk),
	.rst_s         (rst_n),
	               
	.mediant_hs    (per_frame_href ),
	.mediant_vs    (per_frame_vsync ),
	.mediant_de    (per_frame_clken),
	.mediant_img   (per_img_y),
                  
	.grandient_hs  (grandient_hs),
	.grandient_vs  (grandient_vs),
	.grandient_de  (grandient_de),
	.gra_path      (gra_path)//梯度幅值+方向+高低阈值状态
);

canny_nonLocalMaxValue u_anny_nonLocalMaxValue(
	.clk               (clk),
	.rst_s             (rst_n),
	               
	.grandient_vs      (grandient_vs),
	.grandient_hs      (grandient_hs),
	.grandient_de      (grandient_de),
	.gra_path          (gra_path),
	                  
	.post_frame_vsync  (nonLocalMax_vs),
	.post_frame_href   (nonLocalMax_hs),
	.post_frame_clken  (nonLocalMax_de),
	.max_g             (mx_g)
    );

canny_doubleThreshold u_canny_doubleThreshold(
	.clk               (clk),
	.rst_s             (rst_n),
	                   
	.pre_frame_vsync   (nonLocalMax_vs),
	.pre_frame_href    (nonLocalMax_hs),
	.pre_frame_clken   (nonLocalMax_de),
	.max_g             (mx_g),
	                  
	.post_frame_vsync  (post_frame_vsync),
	.post_frame_href   (post_frame_href ),
	.post_frame_clken  (post_frame_clken),
	.canny_out         (post_img_bit)
    );

endmodule
