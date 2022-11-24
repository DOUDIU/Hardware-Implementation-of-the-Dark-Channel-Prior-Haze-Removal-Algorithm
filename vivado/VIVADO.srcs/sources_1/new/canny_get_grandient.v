module canny_get_grandient#(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 640
)(
	input			       clk,
	input			       rst_s,
	
	input			       mediant_hs,
	input			       mediant_vs,
	input			       mediant_de,
	input    	[7:0]      mediant_img,
	
	output		           grandient_hs,
	output		           grandient_vs,
	output		           grandient_de,
	output  reg [15:0]	   gra_path//梯度幅值+方向+高低阈值状态
);
//双阈值的高低阈值
parameter THRESHOLD_LOW  = 10'd50;
parameter THRESHOLD_HIGH = 10'd100;

reg[9:0] Gx_1;//GX第一列计数
reg[9:0] Gx_3;
reg[9:0] Gy_1;
reg[9:0] Gy_3;

reg[10:0] Gx;//Gx Gy 做差分 求偏导
reg[10:0] Gy;

reg[23:0] sqrt_in;//计算梯度值的两个平方和
reg[9:0] sqrt_out;//开平方得到的梯度
reg[10:0] sqrt_rem;//开平方的余数
wire [23:0] sqrt_in_n;
wire [15:0] sqrt_out_n;
wire [10:0] sqrt_rem_n;
wire [6 :0] angle_out;
//9X9矩阵 sobel算子用
wire [7:0]  ma1_1;
wire [7:0]  ma1_2;
wire [7:0]  ma1_3;
wire [7:0]  ma2_1;
wire [7:0]  ma2_2;
wire [7:0]  ma2_3;
wire [7:0]  ma3_1;
wire [7:0]  ma3_2;
wire [7:0]  ma3_3;
//记录行上升沿，可以设置前两行全为8'h00,也可以随其自然
reg edge_de_a;
reg edge_de_b;
wire edge_de;
reg [9:0] row_cnt;
//-----非极大值抑制----
reg[1:0] sign;//Gx Gy  正 负
reg type; // Gx Gy 异号  同号

// reg  path_one;
// wire path_two;
// reg  path_thr;
// wire path_fou;//四个梯度方向

wire start;//判断，；xy轴方向有没有旋中

wire    sobel_vsync;
wire    sobel_href;
wire    sobel_clken;

matrix_generate_3x3 #(
	.DATA_WIDTH(DATA_WIDTH),
	.DATA_DEPTH(DATA_DEPTH)
	)u_matrix_generate_3x3(
    .clk        (clk), 
    .rst_n      (rst_s),
    
    //处理前图像数据
    .per_frame_vsync    (mediant_vs),
    .per_frame_href     (mediant_hs), 
    .per_frame_clken    (mediant_de),
    .per_img_y          (mediant_img),
    
    //处理后的图像数据
    .matrix_frame_vsync (sobel_vsync),
    .matrix_frame_href  (sobel_href),
    .matrix_frame_clken (sobel_clken),
    .matrix_p11         (ma1_1),    
    .matrix_p12         (ma1_2),    
    .matrix_p13         (ma1_3),
    .matrix_p21         (ma2_1),    
    .matrix_p22         (ma2_2),    
    .matrix_p23         (ma2_3),
    .matrix_p31         (ma3_1),    
    .matrix_p32         (ma3_2),    
    .matrix_p33         (ma3_3)
);
//----------------Sobel Parameter--------------------------------------------
//      Gx             Gy				 Pixel
// [+1  0  -1]   [+1  +2  +1]   [ma1_1  ma1_2  ma1_3]
// [+2  0  -2]   [ 0   0   0]   [ma2_1  ma2_2  ma2_3]
// [+1  0  -1]   [-1  -2  -1]   [ma3_1  ma3_2  ma3_3]
//-------------------------------------------------------------
//将GX两列Gy 2列行先加  第一级流水线     
always @ (posedge clk or negedge rst_s)
begin
	if(!rst_s)
		begin
            Gx_1 <= 10'd0;
            Gx_3 <= 10'd0;
		end
	else
		begin
            Gx_1 <= {2'b00,ma1_1} + {1'b0,ma2_1,1'b0} +{2'b0,ma3_1};
            Gx_3 <= {2'b00,ma1_3} + {1'b0,ma2_3,1'b0} +{2'b0,ma3_3};
		end
end

always @ (posedge clk or negedge rst_s)
begin
	if(!rst_s)
		begin
            Gy_1 <= 10'd0;
            Gy_3 <= 10'd0;
		end
	else
		begin
            Gy_1 <= {2'b00,ma1_1} + {1'b0,ma1_2,1'b0} +{2'b0,ma1_3};
            Gy_3 <= {2'b00,ma3_1} + {1'b0,ma3_2,1'b0} +{2'b0,ma3_3};
		end
end

//第二级 ---Gx1 Gx3；Gy1 Gy3  做差  差分 xy方向的偏导  再判断GX GY的正负    
always @(posedge clk or negedge rst_s)
begin
	if(!rst_s)
		begin
		Gx <= 11'd0;
		Gy <= 11'd0;
		sign <= 2'b00;
		end
	else
		begin
		Gx <= (Gx_1 >= Gx_3)? Gx_1 - Gx_3 : Gx_3 - Gx_1;
		Gy <= (Gy_1 >= Gy_3)? Gy_1 - Gy_3 : Gy_3 - Gy_1;
		sign[0] <= (Gx_1 >= Gx_3)? 1'b1 : 1'b0;//判断GX Gy 正负，1 正 0 负
		sign[1] <= (Gy_1 >= Gy_3)? 1'b1 : 1'b0;
		end
end

//第三级 平方和  + GX、GY异同号？+  GX GY 大小级别 + 梯度方向 
//求 Gx^2 Gy^2,提供给开方Ip计算梯度， //梯度的方向就是函数f(x,y)在这点增长最快的方向，梯度的模为方向导数的最大值。

//对Gx Gy  正负的情况做分类  两类  异号 1 同号 0

reg		[8 : 0]		type_d;
always @ (posedge clk or negedge rst_s)
begin
	if(!rst_s)
	   type <= 1'b0;
	else if(sign[0]^sign[1])
        type <= 1'b1;
	else
		type <= 1'b0;
end

always@(posedge clk or negedge rst_s)begin
	if(!rst_s)begin
		type_d	<=		0;
	end
	else begin
		type_d  <=		{type_d[7:0],type};
	end
end


wire        path_fou_f;
wire        path_thr_f;
wire        path_two_f;
wire        path_one_f;
	
cordic_sqrt#(
    .DATA_WIDTH_IN     (11),
    .DATA_WIDTH_OUT    (22),
    .Pipeline          (9 )
)u_cordic_sqrt(
    .clk			(clk),
    .rst_n			(rst_s),
    .sqrt_in_0		(Gx),
    .sqrt_in_1		(Gy),

    .sqrt_out		(sqrt_out_n),
	.angle_out		(angle_out)
);

//  判断完 x y 轴方向 再判断两个对角方向
// 由于坐标轴原点在左上角 ------->  x
//			     |
//			     |
//			    y|
// 同号 为 \   异号为  /  (当然得在 X Y 轴 都不是的情况下)
assign  start 		= (path_one_f | path_thr_f)	?   1'b0 		: 	1'b1;		

assign 	path_fou_f 	= (start) 					?   type_d[8]	:	1'b0;
assign	path_thr_f 	= (angle_out << 2 ) > 135 	? 	1'b1 		:	1'b0;
assign 	path_two_f 	= (start) 					?   ~type_d[8] 	:	1'b0;
assign	path_one_f 	= (angle_out << 2 ) < 45 	? 	1'b1 		:	1'b0;

//第四级
//开方得到梯度，再加上4个方向gra_path[13:10]
//gra_path[15:14]高低阈值，gra_path[13:10]四个方向，gra_path[9:0]梯度幅值
always @(posedge clk or negedge rst_s)
begin
	if(!rst_s)
		gra_path <= 16'd0;
	else if (sqrt_out_n > THRESHOLD_HIGH)
		gra_path <= {1'b1,1'b0,path_fou_f,path_thr_f,path_two_f,path_one_f,sqrt_out_n[9:0]};
	else if (sqrt_out_n > THRESHOLD_LOW)
		gra_path <= {1'b0,1'b1,path_fou_f,path_thr_f,path_two_f,path_one_f,sqrt_out_n[9:0]};
	else
		gra_path <= 16'd0;
end

//对 hs vs de 进行适当的延迟，匹配时钟
reg    [10:0]  sobel_vsync_t     ;
reg    [10:0]  sobel_href_t      ;
reg    [10:0]  sobel_clken_t     ;
always@(posedge clk or negedge rst_s)
begin
  if (!rst_s)
  begin
    sobel_vsync_t    <= 11'd0 ;
    sobel_href_t     <= 11'd0 ;
    sobel_clken_t    <= 11'd0 ;
  end
  else
  begin
	   sobel_vsync_t <= {sobel_vsync_t[9:0], sobel_vsync } ;
	   sobel_href_t  <= {sobel_href_t [9:0], sobel_href  } ;
	   sobel_clken_t <= {sobel_clken_t[9:0], sobel_clken } ;
  end
end

assign grandient_hs = sobel_href_t  [10] ;
assign grandient_vs = sobel_vsync_t [10] ;
assign grandient_de = sobel_clken_t [10] ;

endmodule
