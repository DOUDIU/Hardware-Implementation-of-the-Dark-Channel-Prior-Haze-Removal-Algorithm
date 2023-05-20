module calculate_A(
        input           clk                 ,
        input           rst_n               ,  
        //处理前数据
        input           per_frame_vsync     , 
        input           per_frame_href      ,  
        input           per_frame_clken     , 
        input   [23:0]  per_img             ,       
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

reg                 per_frame_vsync_d1      ; 
reg                 per_frame_href_d1       ;  
reg                 per_frame_clken_d1      ; 



wire    [7 : 0]     pixel_of_r;
wire    [7 : 0]     pixel_of_g;
wire    [7 : 0]     pixel_of_b;
wire    [7 : 0]     pixel_max_of_rgb_1st;
wire    [7 : 0]     pixel_max_of_rgb_2st;

assign      pixel_of_r  =   per_img[23 : 16];
assign      pixel_of_g  =   per_img[15 :  8];
assign      pixel_of_b  =   per_img[ 7 :  0];

assign  pixel_max_of_rgb_1st    =   pixel_of_r > pixel_of_g ? pixel_of_r : pixel_of_g;
assign  pixel_max_of_rgb_2st    =   pixel_of_b > pixel_max_of_rgb_1st ? pixel_of_b : pixel_max_of_rgb_1st;


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        A_value <=  0;
    end
    else if(per_frame_href & per_frame_clken) begin
        A_value <=  A_value > pixel_max_of_rgb_2st ? A_value : pixel_max_of_rgb_2st;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        per_frame_vsync_d1      <=  0               ;
        per_frame_href_d1       <=  0               ;
        per_frame_clken_d1      <=  0               ;
    end
    else begin
        per_frame_vsync_d1      <=  per_frame_vsync ;
        per_frame_href_d1       <=  per_frame_href  ;
        per_frame_clken_d1      <=  per_frame_clken ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        A_value_out <=  8'd230;
    end
    else if(per_frame_vsync_d1 & !per_frame_vsync)begin
        A_value_out <=  A_value;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        A_value_valid   <=  0;
    end
    else if(per_frame_vsync_d1 & !per_frame_vsync)begin
        A_value_valid   <=  1;
    end
    else begin
        A_value_valid   <=  0;
    end
end



assign  post_frame_vsync    =   per_frame_vsync_d1  ;
assign  post_frame_href     =   per_frame_href_d1   ;
assign  post_frame_clken    =   per_frame_clken_d1  ;
assign  post_result         =   A_value_out         ;
assign  post_done           =   A_value_valid       ;

endmodule