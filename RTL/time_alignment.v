module time_alignment(
        input               clk                     ,
        input               rst_n                   ,  
        //处理前数据
        input               per_src_frame_vsync     , 
        input               per_src_frame_href      ,  
        input               per_src_frame_clken     , 
        input   [23 : 0]    per_img                 ,

        input               per_tx_frame_vsync      ,
        input               per_tx_frame_href       ,
        input               per_tx_frame_clken      ,
        input   [7  : 0]    per_tx_img              ,

        input   [7  : 0]    per_A                   ,
        //处理后的数据
        output              post_src_frame_vsync    , 
        output              post_src_frame_href     ,  
        output              post_src_frame_clken    , 
        output  [23 : 0]    post_img                ,

        output              post_tx_frame_vsync     ,
        output              post_tx_frame_href      ,
        output              post_tx_frame_clken     ,
        output  [7  : 0]    post_tx_img             ,

        output  [7  : 0]    post_A                   
);
integer i;

parameter src_delay = 6;

reg                         per_src_frame_vsync_d[src_delay - 1 : 0]    ;
reg                         per_src_frame_href_d[src_delay - 1 : 0]     ;
reg                         per_src_frame_clken_d[src_delay - 1 : 0]    ;
reg     [23 : 0]            per_img_d[src_delay - 1 : 0]                ;

//src_delay
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0; i< src_delay; i = i + 1)begin
            per_src_frame_vsync_d   [ i ]   <=    0;
            per_src_frame_href_d    [ i ]   <=    0;
            per_src_frame_clken_d   [ i ]   <=    0;
            per_img_d               [ i ]   <=    0;
        end
    end
    else begin
        per_src_frame_vsync_d   [ 0 ]          <=    per_src_frame_vsync               ;
        per_src_frame_href_d    [ 0 ]          <=    per_src_frame_href                ;
        per_src_frame_clken_d   [ 0 ]          <=    per_src_frame_clken               ;
        per_img_d               [ 0 ]          <=    per_img                           ;
        for(i = 1; i< src_delay; i = i + 1)begin
            per_src_frame_vsync_d   [ i ]      <=    per_src_frame_vsync_d  [ i - 1 ]  ;
            per_src_frame_href_d    [ i ]      <=    per_src_frame_href_d   [ i - 1 ]  ;
            per_src_frame_clken_d   [ i ]      <=    per_src_frame_clken_d  [ i - 1 ]  ;
            per_img_d               [ i ]      <=    per_img_d              [ i - 1 ]  ;
        end
    end
end

assign      post_src_frame_vsync    =   per_src_frame_vsync_d   [ src_delay - 1 ]   ;
assign      post_src_frame_href     =   per_src_frame_href_d    [ src_delay - 1 ]   ; 
assign      post_src_frame_clken    =   per_src_frame_clken_d   [ src_delay - 1 ]   ;
assign      post_img                =   per_img_d               [ src_delay - 1 ]   ;            



assign      post_tx_frame_vsync     =   per_tx_frame_vsync      ;
assign      post_tx_frame_href      =   per_tx_frame_href       ;
assign      post_tx_frame_clken     =   per_tx_frame_clken      ;
assign      post_tx_img             =   per_tx_img              ;

assign      post_A                  =   per_A;


endmodule
