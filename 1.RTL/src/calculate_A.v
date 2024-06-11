module calculate_A(
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
        output  [7 :0]  post_result         , 
        output          post_done
);

reg     [7 : 0]     A_value                 ;
reg     [7 : 0]     A_value_out             ;
reg                 A_value_valid           ;

reg                 pre_frame_vsync_d1      ; 
reg                 pre_frame_href_d1       ;  
reg                 pre_frame_clken_d1      ; 



wire    [7 : 0]     pixel_of_r;
wire    [7 : 0]     pixel_of_g;
wire    [7 : 0]     pixel_of_b;
wire    [7 : 0]     pixel_max_of_rgb_1st;
wire    [7 : 0]     pixel_max_of_rgb_2st;

assign      pixel_of_r  =   pre_img[23 : 16];
assign      pixel_of_g  =   pre_img[15 :  8];
assign      pixel_of_b  =   pre_img[ 7 :  0];

assign  pixel_max_of_rgb_1st    =   pixel_of_r > pixel_of_g ? pixel_of_r : pixel_of_g;
assign  pixel_max_of_rgb_2st    =   pixel_of_b > pixel_max_of_rgb_1st ? pixel_of_b : pixel_max_of_rgb_1st;


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        A_value <=  0;
    end
    else if(pre_frame_href & pre_frame_clken) begin
        A_value <=  A_value > pixel_max_of_rgb_2st ? A_value : pixel_max_of_rgb_2st;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        pre_frame_vsync_d1      <=  0               ;
        pre_frame_href_d1       <=  0               ;
        pre_frame_clken_d1      <=  0               ;
    end
    else begin
        pre_frame_vsync_d1      <=  pre_frame_vsync ;
        pre_frame_href_d1       <=  pre_frame_href  ;
        pre_frame_clken_d1      <=  pre_frame_clken ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        A_value_out <=  8'd230;
    end
    else if(pre_frame_vsync_d1 & !pre_frame_vsync)begin
        A_value_out <=  A_value;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        A_value_valid   <=  0;
    end
    else if(pre_frame_vsync_d1 & !pre_frame_vsync)begin
        A_value_valid   <=  1;
    end
    else begin
        A_value_valid   <=  0;
    end
end



assign  post_frame_vsync    =   pre_frame_vsync_d1  ;
assign  post_frame_href     =   pre_frame_href_d1   ;
assign  post_frame_clken    =   pre_frame_clken_d1  ;
assign  post_result         =   A_value_out         ;
assign  post_done           =   A_value_valid       ;

endmodule