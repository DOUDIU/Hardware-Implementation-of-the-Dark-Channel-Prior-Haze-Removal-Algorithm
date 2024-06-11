module src_min(
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

reg                 pre_frame_vsync_d1; 
reg                 pre_frame_href_d1;
reg                 pre_frame_clken_d1;

reg     [7 : 0]     pixel_min_of_rgb;
wire    [7 : 0]     pixel_of_r;
wire    [7 : 0]     pixel_of_g;
wire    [7 : 0]     pixel_of_b;
wire    [7 : 0]     pixel_min_of_rgb_1st;
wire    [7 : 0]     pixel_min_of_rgb_2st;

assign      pixel_of_r  =   pre_img[23 : 16];
assign      pixel_of_g  =   pre_img[15 :  8];
assign      pixel_of_b  =   pre_img[ 7 :  0];

assign  pixel_min_of_rgb_1st    =   pixel_of_r > pixel_of_g ? pixel_of_g : pixel_of_r;
assign  pixel_min_of_rgb_2st    =   pixel_of_b > pixel_min_of_rgb_1st ? pixel_min_of_rgb_1st : pixel_of_b;


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        pixel_min_of_rgb    <=  0;
    end
    else if(pre_frame_href & pre_frame_clken)begin
        pixel_min_of_rgb    <=  pixel_min_of_rgb_2st;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        pre_frame_vsync_d1      <=  0;
        pre_frame_href_d1       <=  0;
        pre_frame_clken_d1      <=  0;
    end
    else begin
        pre_frame_vsync_d1      <=  pre_frame_vsync;
        pre_frame_href_d1       <=  pre_frame_href;
        pre_frame_clken_d1      <=  pre_frame_clken;
    end
end

assign  post_frame_vsync    =   pre_frame_vsync_d1;
assign  post_frame_href     =   pre_frame_href_d1 ;
assign  post_frame_clken    =   pre_frame_clken_d1;
assign  post_img            =   pixel_min_of_rgb;


endmodule
