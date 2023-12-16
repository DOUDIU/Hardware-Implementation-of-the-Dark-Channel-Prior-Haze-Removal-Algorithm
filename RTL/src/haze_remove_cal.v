module haze_remove_cal(
    input               clk                     ,
    input               rst_n                   ,  
    //处理前数据
    input               pre_src_frame_vsync     , 
    input               pre_src_frame_href      ,  
    input               pre_src_frame_clken     , 
    input   [23 : 0]    pre_img                 ,

    input               pre_tx_frame_vsync      ,
    input               pre_tx_frame_href       ,
    input               pre_tx_frame_clken      ,
    input   [7  : 0]    pre_tx_img              ,

    input   [7  : 0]    pre_A                   ,

    
    output              post_frame_vsync        , 
    output              post_frame_href         ,  
    output              post_frame_clken        , 
    output  [23 : 0]    post_img                
);

parameter   tx_min   =   8'd26;//min_value of A, 0.1 * 2*8

wire        [7  : 0]    tx_value                 ;
assign                  tx_value =    pre_tx_img < tx_min ? tx_min : pre_tx_img;

reg signed  [32 : 0]    value_tem_r             ;
reg signed  [32 : 0]    value_tem_g             ;
reg signed  [32 : 0]    value_tem_b             ;

reg         [7  : 0]    pre_A_d1                ;
reg         [7  : 0]    tx_value_d1              ;
reg                     pre_tx_frame_vsync_d1   ;
reg                     pre_tx_frame_href_d1    ;
reg                     pre_tx_frame_clken_d1   ;
reg                     pre_tx_frame_vsync_d2   ;
reg                     pre_tx_frame_href_d2    ;
reg                     pre_tx_frame_clken_d2   ;


reg  signed   [10 : 0]     post_img_r;
reg  signed   [10 : 0]     post_img_g;
reg  signed   [10 : 0]     post_img_b;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        pre_A_d1                <=  0                       ;
        tx_value_d1             <=  0                       ;
    end
    else begin
        pre_A_d1                <=  pre_A                   ;
        tx_value_d1             <=  tx_value                ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        value_tem_r     <=  0;
        value_tem_g     <=  0;
        value_tem_b     <=  0;
    end
    else begin
        value_tem_r     <=  (( pre_img[23 : 16] - pre_A ) <<< 8 ) + pre_A * tx_value;
        value_tem_g     <=  (( pre_img[15 :  8] - pre_A ) <<< 8 ) + pre_A * tx_value;
        value_tem_b     <=  (( pre_img[ 7 :  0] - pre_A ) <<< 8 ) + pre_A * tx_value;
    end
end

//critical path : use xilinx IP 'divider generator' to replace '/';
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        post_img_r      <=  0;
        post_img_g      <=  0;
        post_img_b      <=  0;
    end
    else begin
        post_img_r      <=  value_tem_r / tx_value_d1 ;//+ pre_A_d1 ;
        post_img_g      <=  value_tem_g / tx_value_d1 ;//+ pre_A_d1 ;
        post_img_b      <=  value_tem_b / tx_value_d1 ;//+ pre_A_d1 ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        pre_tx_frame_vsync_d1   <=  0                       ;
        pre_tx_frame_href_d1    <=  0                       ;
        pre_tx_frame_clken_d1   <=  0                       ;
    end
    else begin
        pre_tx_frame_vsync_d1   <=  pre_tx_frame_vsync      ;
        pre_tx_frame_href_d1    <=  pre_tx_frame_href       ;
        pre_tx_frame_clken_d1   <=  pre_tx_frame_clken      ;
        pre_tx_frame_vsync_d2   <=  pre_tx_frame_vsync_d1   ;
        pre_tx_frame_href_d2    <=  pre_tx_frame_href_d1    ;
        pre_tx_frame_clken_d2   <=  pre_tx_frame_clken_d1   ;
    end
end

assign  post_img            =   {post_img_r[7 : 0],post_img_g[7 : 0],post_img_b[7 : 0]}     ;
assign  post_frame_vsync    =   pre_tx_frame_vsync_d2                                       ;
assign  post_frame_href     =   pre_tx_frame_href_d2                                        ;
assign  post_frame_clken    =   pre_tx_frame_clken_d2                                       ;
                                      


endmodule
