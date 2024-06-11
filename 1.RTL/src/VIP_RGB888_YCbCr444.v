module VIP_RGB888_YCbCr444
(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//Image data prepred to be processd
	input				pre_frame_vsync,	//Prepared Image data vsync valid signal
	input				pre_frame_href,		//Prepared Image data href vaild  signal
	input				pre_frame_clken,	//Prepared Image data output/capture enable clock	
	input		[7:0]	pre_img_red,		//Prepared Image red data to be processed
	input		[7:0]	pre_img_green,		//Prepared Image green data to be processed
	input		[7:0]	pre_img_blue,		//Prepared Image blue data to be processed
	
	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock	
	output		[7:0]	post_img_Y,			//Processed Image brightness output
	output		[7:0]	post_img_Cb,		//Processed Image blue shading output
	output		[7:0]	post_img_Cr			//Processed Image red shading output
);

//--------------------------------------------
/*********************************************
//Refer to <OV7725 Camera Module Software Applicaton Note> page 5
	Y 	=	(77 *R 	+ 	150*G 	+ 	29 *B)>>8
	Cb 	=	(-43*R	- 	85 *G	+ 	128*B)>>8 + 128
	Cr 	=	(131*R 	-	110*G  	-	21 *B)>>8 + 128
	Cr0(i, j) = 0.511*R(i, j) - 0.428*G(i, j) - 0.083*B(i, j) + 128;
--->
	Y 	=	(77 *R 	+ 	150*G 	+ 	29 *B)>>8
	Cb 	=	(-43*R	- 	85 *G	+ 	128*B + 32768)>>8
	Cr 	=	(128*R 	-	107*G  	-	21 *B + 32768)>>8
**********************************************/
//Step 1
reg	[15:0]	img_red_r0,		img_red_r1,		img_red_r2;	
reg	[15:0]	img_green_r0,	img_green_r1,	img_green_r2; 
reg	[15:0]	img_blue_r0,	img_blue_r1,	img_blue_r2; 
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		img_red_r0		<=	0; 		
		img_red_r1		<=	0; 		
		img_red_r2		<=	0; 	
		img_green_r0	<=	0; 		
		img_green_r1	<=	0; 		
		img_green_r2	<=	0; 	
		img_blue_r0		<=	0; 		
		img_blue_r1		<=	0; 		
		img_blue_r2		<=	0; 			
		end
	else
		begin
		img_red_r0		<=	pre_img_red 	* 	8'd77; 		
		img_red_r1		<=	pre_img_red 	* 	8'd43; 	
		img_red_r2		<=	pre_img_red 	* 	8'd131; 		
		img_green_r0	<=	pre_img_green 	* 	8'd150; 		
		img_green_r1	<=	pre_img_green 	* 	8'd85; 			
		img_green_r2	<=	pre_img_green 	* 	8'd110; 
		img_blue_r0		<=	pre_img_blue 	* 	8'd29; 		
		img_blue_r1		<=	pre_img_blue 	* 	8'd128; 			
		img_blue_r2		<=	pre_img_blue 	* 	8'd21; 		
		end
end

//--------------------------------------------------
//Step 2
reg	[15:0]	img_Y_r0;	
reg	[15:0]	img_Cb_r0; 
reg	[15:0]	img_Cr_r0; 
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		img_Y_r0	<=	0; 		
		img_Cb_r0	<=	0; 		
		img_Cr_r0	<=	0; 	
		end
	else
		begin
		img_Y_r0	<=	img_red_r0 	+ 	img_green_r0 	+ 	img_blue_r0; 		
		img_Cb_r0	<=	img_blue_r1 - 	img_red_r1 		- 	img_green_r1	+	16'd32768; 		
		img_Cr_r0	<=	img_red_r2 	- 	img_green_r2 	- 	img_blue_r2		+	16'd32768; 		
		end
end

//--------------------------------------------------
//Step 3
reg	[7:0]	img_Y_r1;	
reg	[7:0]	img_Cb_r1; 
reg	[7:0]	img_Cr_r1; 
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		img_Y_r1	<=	0; 		
		img_Cb_r1	<=	0; 		
		img_Cr_r1	<=	0; 	
		end
	else
		begin
		img_Y_r1	<=	img_Y_r0[15:8];
		img_Cb_r1	<=	img_Cb_r0[15:8];
		img_Cr_r1	<=	img_Cr_r0[15:8]; 
		end
end



//------------------------------------------
//lag 3 clocks signal sync  
reg	[2:0]	pre_frame_vsync_r;
reg	[2:0]	pre_frame_href_r;	
reg	[2:0]	pre_frame_clken_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		pre_frame_vsync_r <= 0;
		pre_frame_href_r <= 0;
		pre_frame_clken_r <= 0;
		end
	else
		begin
		pre_frame_vsync_r 	<= 	{pre_frame_vsync_r[1:0], 	pre_frame_vsync	};
		pre_frame_href_r 	<= 	{pre_frame_href_r[1:0], 	pre_frame_href	};
		pre_frame_clken_r 	<= 	{pre_frame_clken_r[1:0], 	pre_frame_clken	};
		end
end
assign	post_frame_vsync 	= 	pre_frame_vsync_r[2];
assign	post_frame_href 	= 	pre_frame_href_r[2];
assign	post_frame_clken 	= 	pre_frame_clken_r[2];
assign	post_img_Y 			= 	img_Y_r1 ;
assign	post_img_Cb			=	img_Cb_r1;
assign	post_img_Cr			= 	img_Cr_r1;

endmodule
