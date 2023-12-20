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
// `define Xilinx_IP

parameter   tx_min   =   8'd26;//min_value of A, 0.1 * 2*8

wire        [7  : 0]    tx_value                 ;
assign                  tx_value =    pre_tx_img < tx_min ? tx_min : pre_tx_img;

reg signed  [16 : 0]    value_tem_r             ;
reg signed  [16 : 0]    value_tem_g             ;
reg signed  [16 : 0]    value_tem_b             ;

reg         [7  : 0]    pre_A_d1                ;
reg         [7  : 0]    tx_value_d1              ;


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

`ifdef Xilinx_IP
    wire  signed    [10 : 0]    post_img_r;
    wire  signed    [10 : 0]    post_img_g;
    wire  signed    [10 : 0]    post_img_b;
    wire            [7  : 0]    temp_r;
    wire            [7  : 0]    temp_g;
    wire            [7  : 0]    temp_b;

    integer i;

    reg                     pre_tx_frame_vsync_d      [36:0] ;
    reg                     pre_tx_frame_href_d       [36:0] ;
    reg                     pre_tx_frame_clken_d      [36:0] ;

    div_gen_0 u_div_gen_0(
    .aclk                     (clk    ),                                      // input wire aclk
    .s_axis_divisor_tvalid    (1      ),    // input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata     (tx_value_d1),      // input wire [7 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid   (1),  // input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata    (value_tem_r),    // input wire [39 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid       (),          // output wire m_axis_dout_tvalid
    .m_axis_dout_tdata        ({post_img_r,temp_r})            // output wire [47 : 0] m_axis_dout_tdata
    );
    div_gen_0 u_div_gen_1(
    .aclk                     (clk    ),                                      // input wire aclk
    .s_axis_divisor_tvalid    (1      ),    // input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata     (tx_value_d1),      // input wire [7 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid   (1),  // input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata    (value_tem_g),    // input wire [39 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid       (),          // output wire m_axis_dout_tvalid
    .m_axis_dout_tdata        ({post_img_g,temp_g})            // output wire [47 : 0] m_axis_dout_tdata
    );
    div_gen_0 u_div_gen_2(
    .aclk                     (clk    ),                                      // input wire aclk
    .s_axis_divisor_tvalid    (1      ),    // input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata     (tx_value_d1),      // input wire [7 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid   (1),  // input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata    (value_tem_b),    // input wire [39 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid       (),          // output wire m_axis_dout_tvalid
    .m_axis_dout_tdata        ({post_img_b,temp_b})            // output wire [47 : 0] m_axis_dout_tdata
    );

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i = 0; i < 37; i = i + 1) begin
                pre_tx_frame_vsync_d[i]   <=  0                       ;
                pre_tx_frame_href_d[i]    <=  0                       ;
                pre_tx_frame_clken_d[i]   <=  0                       ;
            end
        end
        else begin
            pre_tx_frame_vsync_d[0]     <=  pre_tx_frame_vsync      ;
            pre_tx_frame_href_d[0]      <=  pre_tx_frame_href       ;
            pre_tx_frame_clken_d[0]     <=  pre_tx_frame_clken      ;
            for(i = 1; i < 37; i = i + 1) begin
                pre_tx_frame_vsync_d[i]     <=  pre_tx_frame_vsync_d[i-1] ;
                pre_tx_frame_href_d[i]      <=  pre_tx_frame_href_d[i-1]  ;
                pre_tx_frame_clken_d[i]     <=  pre_tx_frame_clken_d[i-1] ;
            end
        end
    end
    
    assign  post_img            =   {post_img_b[7 : 0],post_img_g[7 : 0],post_img_r[7 : 0]}     ;
    assign  post_frame_vsync    =   pre_tx_frame_vsync_d[36]                                    ;
    assign  post_frame_href     =   pre_tx_frame_href_d[36]                                     ;
    assign  post_frame_clken    =   pre_tx_frame_clken_d[36]                                    ;
`else

    reg  signed   [10 : 0]     post_img_r;
    reg  signed   [10 : 0]     post_img_g;
    reg  signed   [10 : 0]     post_img_b;
    reg                     pre_tx_frame_vsync_d1   ;
    reg                     pre_tx_frame_href_d1    ;
    reg                     pre_tx_frame_clken_d1   ;
    reg                     pre_tx_frame_vsync_d2   ;
    reg                     pre_tx_frame_href_d2    ;
    reg                     pre_tx_frame_clken_d2   ;
    
    //critical path : use Xilinx IP 'divider generator' to replace '/';
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            post_img_r      <=  0;
            post_img_g      <=  0;
            post_img_b      <=  0;
        end
        else begin
            post_img_r      <=  value_tem_r / tx_value_d1;
            post_img_g      <=  value_tem_g / tx_value_d1;
            post_img_b      <=  value_tem_b / tx_value_d1;
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

`endif                                   


endmodule
