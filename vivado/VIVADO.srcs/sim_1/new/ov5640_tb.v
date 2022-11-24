`timescale 1ns / 1ns

//使用BMP图片格式仿真VIP视频图像处理算法
module bmp_sim_VIP_tb();
 
integer iBmpFileId;                 //输入BMP图片

integer oBmpFileId_1;                 //输出BMP图片 1
integer oBmpFileId_2;                 //输出BMP图片 2
integer oBmpFileId_3;                 //输出BMP图片 3
integer oBmpFileId_4;                 //输出BMP图片 3

integer oTxtFileId;                 //输入TXT文本
 integer oTxtFileId_2;                 //输入TXT文本      
  
integer iIndex = 0;                 //输出BMP数据索引
integer pixel_index = 0;            //输出像素数据索引 
        
integer iCode;      
        
integer iBmpWidth;                  //输入BMP 宽度
integer iBmpHight;                  //输入BMP 高度
integer iBmpSize;                   //输入BMP 字节数
integer iDataStartIndex;            //输入BMP 像素数据偏移量
    
reg [7:0]   rBmpData [0:2000000];    //用于寄存输入BMP图片中的字节数据（包括54字节的文件头）

reg [7:0]   Vip_BmpData_1 [0:2000000]; //用于寄存视频图像处理之后 的BMP图片 数据 
reg [7:0]   Vip_BmpData_2 [0:2000000]; //用于寄存视频图像处理之后 的BMP图片 数据 
reg [7:0]   Vip_BmpData_3 [0:2000000]; //用于寄存视频图像处理之后 的BMP图片 数据 

reg [7:0]   rBmpWord;                //输出BMP图片时用于寄存数据（以word为单位，即4byte）
reg [7:0]   rBmpWord_2;                //输出BMP图片时用于寄存数据（以word为单位，即4byte）

reg [7:0]   rBmpWord_8;
reg [7:0]   pixel_data;              //输出视频流时的像素数据

reg clk;
reg rst_n;

reg [7:0] vip_pixel_data_1 [0:921600];   	//640x480x3
reg [7:0] vip_pixel_data_2 [0:921600];   	//640x480x3
reg [7:0] vip_pixel_data_3 [0:921600];   	//640x480x3
reg [7:0] vip_pixel_data_4 [0:921600];   	//640x480x3
//---------------------------------------------
initial begin
    iBmpFileId      = $fopen("../../../../../pic/duck_fog.bmp","rb");
    //将输入BMP图片加载到数组中
	iCode = $fread(rBmpData,iBmpFileId);
    //根据BMP图片文件头的格式，分别计算出图片的 宽度 /高度 /像素数据偏移量 /图片字节数
	iBmpWidth       = {rBmpData[21],rBmpData[20],rBmpData[19],rBmpData[18]};
	iBmpHight       = {rBmpData[25],rBmpData[24],rBmpData[23],rBmpData[22]};
	iBmpSize        = {rBmpData[ 5],rBmpData[ 4],rBmpData[ 3],rBmpData[ 2]};
	iDataStartIndex = {rBmpData[13],rBmpData[12],rBmpData[11],rBmpData[10]};
    //关闭输入BMP图片
	$fclose(iBmpFileId);
	
    //延迟13ms，等待第一帧VIP处理结束
     #13000000       
     
    //输出第一张
	oBmpFileId_1 = $fopen("../../../../../pic/canny_demo.bmp","wb+");
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_1[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_1[iIndex] = vip_pixel_data_1[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		rBmpWord = Vip_BmpData_1[iIndex];
		$fwrite(oBmpFileId_1,"%c",rBmpWord);
	end
    $fclose(oBmpFileId_1);

    //输出第二张
	oBmpFileId_2 = $fopen("../../../../../pic/gauss_demo.bmp","wb+");
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_2[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_2[iIndex] = vip_pixel_data_2[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		rBmpWord = Vip_BmpData_2[iIndex];
		$fwrite(oBmpFileId_2,"%c",rBmpWord);
	end
    $fclose(oBmpFileId_2);

    //输出第三张
	oBmpFileId_3 = $fopen("../../../../../pic/median_demo.bmp","wb+");
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_3[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_3[iIndex] = vip_pixel_data_3[iIndex-54];
	end
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		rBmpWord = Vip_BmpData_3[iIndex];
		$fwrite(oBmpFileId_3,"%c",rBmpWord);
	end
    $fclose(oBmpFileId_3);

    
    // //输出第四张
	// oBmpFileId_1 = $fopen("../../../../../pic/canny_demo.bmp","wb+");
	// for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
	// 	if(iIndex < 54)
    //         Vip_BmpData_1[iIndex] = rBmpData[iIndex];
    //     else
    //         Vip_BmpData_1[iIndex] = vip_pixel_data_1[iIndex-54];
	// end
    // //将数组中的数据写到输出BMP图片中    
	// for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
	// 	rBmpWord = Vip_BmpData_1[iIndex];
	// 	$fwrite(oBmpFileId_1,"%c",rBmpWord);
	// end
    // $fclose(oBmpFileId_1);
end

//--------------------------------------------- 


//---------------------------------------------		
//初始化时钟和复位信号
initial begin
    clk     = 1;
    rst_n   = 0;
    #110
    rst_n   = 1;
end 

//产生50MHz时钟
always #10 clk = ~clk;
 
//---------------------------------------------		
//在时钟驱动下，从数组中读出像素数据，用于在Modelsim中查看BMP中的数据 
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        pixel_data  <=  8'd0;
        pixel_index <=  0;
    end
    else begin
        pixel_data  <=  rBmpData[pixel_index];
        pixel_index <=  pixel_index+1;
    end
end
 
//---------------------------------------------
//产生摄像头时序 

wire		cmos_vsync ;
reg			cmos_href;
wire        cmos_clken;
reg	[23:0]	cmos_data;	
		 
reg         cmos_clken_r;

reg [31:0]  cmos_index;

parameter [10:0] IMG_HDISP = 11'd640;
parameter [10:0] IMG_VDISP = 11'd480;

localparam H_SYNC = 11'd5;		
localparam H_BACK = 11'd5;		
localparam H_DISP = IMG_HDISP;	
localparam H_FRONT = 11'd5;		
localparam H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;	

localparam V_SYNC = 11'd1;		
localparam V_BACK = 11'd0;		
localparam V_DISP = IMG_VDISP;	
localparam V_FRONT = 11'd1;		
localparam V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT;

//---------------------------------------------
//模拟 OV7725/OV5640 驱动模块输出的时钟使能
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_clken_r <= 0;
	else
        cmos_clken_r <= ~cmos_clken_r;
end

//---------------------------------------------
//水平计数器
	reg	[10:0]	hcnt;
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)
			hcnt <= 11'd0;
		else if(cmos_clken_r) 
			hcnt <= (hcnt < H_TOTAL - 1'b1) ? hcnt + 1'b1 : 11'd0;
	end

//---------------------------------------------


//竖直计数器
	reg	[10:0]	vcnt;
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)
			vcnt <= 11'd0;		
		else if(cmos_clken_r) begin
			if(hcnt == H_TOTAL - 1'b1)
				vcnt <= (vcnt < V_TOTAL - 1'b1) ? vcnt + 1'b1 : 11'd0;
			else
				vcnt <= vcnt;
		end
	end

//---------------------------------------------

//场同步
reg	cmos_vsync_r;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_vsync_r <= 1'b0;			//H: Vaild, L: inVaild
	else begin
		if(vcnt <= V_SYNC - 1'b1)
			cmos_vsync_r <= 1'b0; 	//H: Vaild, L: inVaild
		else
			cmos_vsync_r <= 1'b1; 	//H: Vaild, L: inVaild
    end
end
assign	cmos_vsync	= cmos_vsync_r;

//---------------------------------------------


//行有效
wire	frame_valid_ahead =  ( vcnt >= V_SYNC + V_BACK  && vcnt < V_SYNC + V_BACK + V_DISP
                            && hcnt >= H_SYNC + H_BACK  && hcnt < H_SYNC + H_BACK + H_DISP ) 
						? 1'b1 : 1'b0;
      
reg			cmos_href_r;      
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href_r <= 0;
	else begin
		if(frame_valid_ahead)
			cmos_href_r <= 1;
		else
			cmos_href_r <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href <= 0;
	else
        cmos_href <= cmos_href_r;
end

assign cmos_clken = cmos_href & cmos_clken_r;

//-------------------------------------
//从数组中以视频格式输出像素数据
wire [10:0] x_pos;
wire [10:0] y_pos;

assign x_pos = frame_valid_ahead ? (hcnt - (H_SYNC + H_BACK )) : 0;
assign y_pos = frame_valid_ahead ? (vcnt - (V_SYNC + V_BACK )) : 0;

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
       cmos_index   <=  0;
       cmos_data    <=  24'd0;
   end
   else begin
       cmos_index   <=  y_pos * 1920  + x_pos*3 + 54;         //  3*(y*640 + x) + 54
       cmos_data    <=  {rBmpData[cmos_index], rBmpData[cmos_index+1] , rBmpData[cmos_index+2]};
   end
end
 
//-------------------------------------
//VIP算法--彩色转灰度

wire 		per_frame_vsync	=	cmos_vsync ;	
wire 		per_frame_href	=	cmos_href;	
wire 		per_frame_clken	=	cmos_clken;	
wire [7:0]	per_img_red		=	cmos_data[ 7: 0];	   	
wire [7:0]	per_img_green	=	cmos_data[15: 8];   	            
wire [7:0]	per_img_blue	=	cmos_data[23:16];   	            


wire 		post0_frame_vsync;   
wire 		post0_frame_href ;   
wire 		post0_frame_clken;    
wire [7:0]	post0_img_Y      ;   
wire [7:0]	post0_img_Cb     ;   
wire [7:0]	post0_img_Cr     ;   

VIP_RGB888_YCbCr444	u_VIP_RGB888_YCbCr444
(
	//global clock
	.clk				(clk                ),					
	.rst_n				(rst_n              ),				

	//Image data prepred to be processd
	.per_frame_vsync	(per_frame_vsync    ),		
	.per_frame_href		(per_frame_href     ),		
	.per_frame_clken	(per_frame_clken    ),		
	.per_img_red		(per_img_red        ),			
	.per_img_green		(per_img_green      ),		
	.per_img_blue		(per_img_blue       ),			
	
	//Image data has been processd
	.post_frame_vsync	(post0_frame_vsync	),	
	.post_frame_href	(post0_frame_href 	),		
	.post_frame_clken	(post0_frame_clken	),	
	.post_img_Y			(post0_img_Y 		),			
	.post_img_Cb		(post0_img_Cb		),			
	.post_img_Cr		(post0_img_Cr		)			
);

wire        		haze_remove_vsync		  ;
wire        		haze_remove_hsync		  ;
wire        		haze_remove_de   		  ;
wire        [7:0]	img_haze_remove		  	  ;


haze_remove_top u_haze_remove_top(
        .clk                 (clk                ),
        .rst_n               (rst_n              ),  
        //处理前数据
        .per_frame_vsync     (per_frame_vsync    ), 
        .per_frame_href      (per_frame_href     ),  
        .per_frame_clken     (per_frame_clken    ), 
        .per_img             ({per_img_red,per_img_green,per_img_blue}),       
        //处理后的数据
        .post_frame_vsync    (haze_remove_vsync	 ), 
        .post_frame_href     (haze_remove_hsync	 ),  
        .post_frame_clken    (haze_remove_de   	 ), 
        .post_img            (img_haze_remove    )
    );


//灰度图中值滤波
wire        		median_vsync		  ;
wire        		median_hsync		  ;
wire        		median_de   		  ;
wire        [7:0]	img_median		  	  ;

// vip_gray_median_filter u_vip_gray_median_filter(
//     .clk    (clk),   
//     .rst_n  (rst_n), 
    
//     //预处理图像数据
//     .pe_frame_vsync (post0_frame_vsync	),      // vsync信号
//     .pe_frame_href  (post0_frame_href 	),       // href信号
//     .pe_frame_clken (post0_frame_clken	),      // data enable信号
//     .pe_img_y       (post0_img_Y 		),               
                                           
//     //处理后的图像数据                     
//     .pos_frame_vsync (median_vsync		),        // vsync信号
//     .pos_frame_href  (median_hsync		),        // href信号
//     .pos_frame_clken (median_de   		),           // data enable信号
//     .pos_img_y       (img_median		)          //中值滤波后的灰度数据
// );

//gaussian滤波
wire        		gauss_vsync		  ;
wire        		gauss_hsync		  ;
wire        		gauss_de   		  ;
wire        [7:0]	img_gauss     	  ;

// image_gaussian_filter u_image_gaussian_filter
// (
// 	.clk                (clk),
// 	.rst_n              (rst_n),
    
// 	.per_frame_vsync    (post0_frame_vsync	),
// 	.per_frame_href     (post0_frame_href 	),	
// 	.per_frame_clken    (post0_frame_clken	),
// 	.per_img_gray       (post0_img_Y 		),	
    
// 	.post_frame_vsync   (gauss_vsync        ),	
// 	.post_frame_href    (gauss_hsync        ),	
// 	.post_frame_clken   (gauss_de           ),		
// 	.post_img_gray      (img_gauss          )
// );

//canny边缘检测
wire        canny_vsync  ;
wire        canny_hsync  ;
wire        canny_de     ;
wire        img_canny    ;

// canny_edge_detect_top u_canny_edge_detect_top(
//         .clk                (clk),             
//         .rst_n              (rst_n),  
                            
//         .per_frame_vsync    (gauss_vsync    ), 
//         .per_frame_href     (gauss_hsync    ),  
//         .per_frame_clken    (gauss_de       ), 
//         .per_img_y          (img_gauss      ),     
                          
//         .post_frame_vsync   (canny_vsync    ), 
//         .post_frame_href    (canny_hsync    ),  
//         .post_frame_clken   (canny_de       ), 
//         .post_img_bit       (img_canny      )
//     );
	

//-------------------------------------
//第一张图
wire        PIC1_vip_out_frame_vsync;
wire        PIC1_vip_out_frame_href ;
wire        PIC1_vip_out_frame_clken;
wire        [7:0]      PIC1_vip_out_img_R;
wire        [7:0]      PIC1_vip_out_img_G;
wire        [7:0]      PIC1_vip_out_img_B;

 assign PIC1_vip_out_frame_vsync 	= canny_vsync	        ;   
 assign PIC1_vip_out_frame_href  	= canny_hsync	        ;   
 assign PIC1_vip_out_frame_clken 	= canny_de		        ; 
 assign PIC1_vip_out_img_R 			={8{img_canny}}         ;
 assign PIC1_vip_out_img_G 			={8{img_canny}}         ;
 assign PIC1_vip_out_img_B 			={8{img_canny}}	        ;
 

reg [31:0]  PIC1_vip_cnt;
reg         PIC1_vip_vsync_r;    //寄存VIP输出的场同步 
reg         PIC1_vip_out_en;     //寄存VIP处理图像的使能信号，仅维持一帧的时间

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC1_vip_vsync_r   <=  1'b0;
   else 
        PIC1_vip_vsync_r   <=  PIC1_vip_out_frame_vsync;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC1_vip_out_en    <=  1'b1;
   else if(PIC1_vip_vsync_r & (!PIC1_vip_out_frame_vsync))  //第一帧结束之后，使能拉低
        PIC1_vip_out_en    <=  1'b0;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        PIC1_vip_cnt <=  32'd0;
   end
   else if(PIC1_vip_out_en) begin
        if(PIC1_vip_out_frame_href & PIC1_vip_out_frame_clken) begin
            PIC1_vip_cnt <=  PIC1_vip_cnt + 3;
            vip_pixel_data_1[PIC1_vip_cnt+0] <= PIC1_vip_out_img_R;
            vip_pixel_data_1[PIC1_vip_cnt+1] <= PIC1_vip_out_img_G;
            vip_pixel_data_1[PIC1_vip_cnt+2] <= PIC1_vip_out_img_B;
        end
   end
end

//-------------------------------------
//第二张图
wire        PIC2_vip_out_frame_vsync;
wire        PIC2_vip_out_frame_href ;
wire        PIC2_vip_out_frame_clken;
wire        [7:0]      PIC2_vip_out_img_R;
wire        [7:0]      PIC2_vip_out_img_G;
wire        [7:0]      PIC2_vip_out_img_B;

 assign PIC2_vip_out_frame_vsync 	= gauss_vsync       ;        		   
 assign PIC2_vip_out_frame_href  	= gauss_hsync       ;        		   
 assign PIC2_vip_out_frame_clken 	= gauss_de          ;        		 
 assign PIC2_vip_out_img_R 			= img_gauss         ;        		
 assign PIC2_vip_out_img_G 			= img_gauss         ;
 assign PIC2_vip_out_img_B 			= img_gauss	        ;
reg [31:0]  PIC2_vip_cnt;
reg         PIC2_vip_vsync_r;    //寄存VIP输出的场同步 
reg         PIC2_vip_out_en;     //寄存VIP处理图像的使能信号，仅维持一帧的时间

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC2_vip_vsync_r   <=  1'b0;
   else 
        PIC2_vip_vsync_r   <=  PIC2_vip_out_frame_vsync;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC2_vip_out_en    <=  1'b1;
   else if(PIC2_vip_vsync_r & (!PIC2_vip_out_frame_vsync))  //第一帧结束之后，使能拉低
        PIC2_vip_out_en    <=  1'b0;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        PIC2_vip_cnt <=  32'd0;
   end
   else if(PIC2_vip_out_en) begin
        if(PIC2_vip_out_frame_href & PIC2_vip_out_frame_clken) begin
            PIC2_vip_cnt <=  PIC2_vip_cnt + 3;
            vip_pixel_data_2[PIC2_vip_cnt+0] <= PIC2_vip_out_img_R;
            vip_pixel_data_2[PIC2_vip_cnt+1] <= PIC2_vip_out_img_G;
            vip_pixel_data_2[PIC2_vip_cnt+2] <= PIC2_vip_out_img_B;
        end
   end
end

//-------------------------------------
//第三张图
wire        PIC3_vip_out_frame_vsync;
wire        PIC3_vip_out_frame_href ;
wire        PIC3_vip_out_frame_clken;
wire        [7:0]      PIC3_vip_out_img_R;
wire        [7:0]      PIC3_vip_out_img_G;
wire        [7:0]      PIC3_vip_out_img_B;

 assign PIC3_vip_out_frame_vsync 	= haze_remove_vsync	 ;		   
 assign PIC3_vip_out_frame_href  	= haze_remove_hsync	 ;		   
 assign PIC3_vip_out_frame_clken 	= haze_remove_de   	 ;		 
 assign PIC3_vip_out_img_R 			= img_haze_remove    ;		
 assign PIC3_vip_out_img_G 			= img_haze_remove    ;
 assign PIC3_vip_out_img_B 			= img_haze_remove	 ;
reg [31:0]  PIC3_vip_cnt;
reg         PIC3_vip_vsync_r;    //寄存VIP输出的场同步 
reg         PIC3_vip_out_en;     //寄存VIP处理图像的使能信号，仅维持一帧的时间

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC3_vip_vsync_r   <=  1'b0;
   else 
        PIC3_vip_vsync_r   <=  PIC3_vip_out_frame_vsync;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC3_vip_out_en    <=  1'b1;
   else if(PIC3_vip_vsync_r & (!PIC3_vip_out_frame_vsync))  //第一帧结束之后，使能拉低
        PIC3_vip_out_en    <=  1'b0;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        PIC3_vip_cnt <=  32'd0;
   end
   else if(PIC3_vip_out_en) begin
        if(PIC3_vip_out_frame_href & PIC3_vip_out_frame_clken) begin
            PIC3_vip_cnt <=  PIC3_vip_cnt + 3;
            vip_pixel_data_3[PIC3_vip_cnt+0] <= PIC3_vip_out_img_R;
            vip_pixel_data_3[PIC3_vip_cnt+1] <= PIC3_vip_out_img_G;
            vip_pixel_data_3[PIC3_vip_cnt+2] <= PIC3_vip_out_img_B;
        end
   end
end


endmodule 