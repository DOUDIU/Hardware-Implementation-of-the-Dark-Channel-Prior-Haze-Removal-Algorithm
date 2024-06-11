module tx_get(
        input               clk                 ,
        input               rst_n               ,  
        //处理前数据
        input               pre_frame_vsync     , 
        input               pre_frame_href      ,  
        input               pre_frame_clken     , 
        input   [7  : 0]    pre_img             ,
        input   [7  : 0]    A_value             ,
        //处理后的数据
        output              post_frame_vsync    , 
        output              post_frame_href     ,  
        output              post_frame_clken    , 
        output  [7  : 0]    post_img  
);

parameter modification_value = 8'd243;    //modification_value=0.95*2^8,

reg         [15 : 0]    modify_A            ;

reg                     pre_frame_vsync_d1  ;
reg                     pre_frame_href_d1   ;
reg                     pre_frame_clken_d1  ;
reg         [7  : 0]    A_value_d1          ;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        modify_A    <=  0;
    end
    else begin
        modify_A    <=  (pre_img << 8) - pre_img - (pre_img << 2) - (pre_img << 3); //pre_img * modification_value
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        pre_frame_vsync_d1      <=  0                   ;
        pre_frame_href_d1       <=  0                   ;
        pre_frame_clken_d1      <=  0                   ;
        A_value_d1              <=  0                   ;
    end
    else begin
        pre_frame_vsync_d1      <=  pre_frame_vsync     ;
        pre_frame_href_d1       <=  pre_frame_href      ;
        pre_frame_clken_d1      <=  pre_frame_clken     ;
        A_value_d1              <=  A_value             ;
    end
end


assign      post_frame_vsync    =   pre_frame_vsync_d1  ;
assign      post_frame_href     =   pre_frame_href_d1   ;
assign      post_frame_clken    =   pre_frame_clken_d1  ;
assign      post_img            =   8'd255  -   modify_A / A_value_d1;

endmodule
