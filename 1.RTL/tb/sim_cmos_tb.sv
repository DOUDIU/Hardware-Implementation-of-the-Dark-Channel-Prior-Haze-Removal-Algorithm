module sim_cmos#(
		parameter PIC_PATH 	= "../../../../../../pic/duck_fog.bmp"
	,	parameter IMG_HDISP = 640
	,	parameter IMG_VDISP = 480
)(
		input			clk
	, 	input			rst_n

	,	output			CMOS_VSYNC
	, 	output			CMOS_HREF
	, 	output			CMOS_CLKEN
	, 	output	[23:0]	CMOS_DATA
	,	output  [10:0]	X_POS
	,	output  [10:0]	Y_POS
);

integer iBmpFileId;                 

integer oTxtFileId;                 
        
integer iIndex = 0;                 

integer iCode;      
        
integer iBmpWidth;                  //输入BMP 宽度
integer iBmpHight;                  //输入BMP 高度
integer iBmpSize;                   //输入BMP 字节数
integer iDataStartIndex;            //输入BMP 像素数据偏移量

localparam BMP_SIZE   = 54 + IMG_HDISP * IMG_VDISP * 3 - 1;     //输出BMP 字节数
    
reg [ 7:0] rBmpData [0:BMP_SIZE];  

integer i,j;


//---------------------------------------------
initial begin
	iBmpFileId	= 	$fopen(PIC_PATH,"rb");

	iCode = $fread(rBmpData,iBmpFileId);

	//根据BMP图片文件头的格式，分别计算出图片的 宽度 /高度 /像素数据偏移量 /图片字节数
	iBmpWidth       = {rBmpData[21],rBmpData[20],rBmpData[19],rBmpData[18]};
	iBmpHight       = {rBmpData[25],rBmpData[24],rBmpData[23],rBmpData[22]};
	iBmpSize        = {rBmpData[ 5],rBmpData[ 4],rBmpData[ 3],rBmpData[ 2]};
	iDataStartIndex = {rBmpData[13],rBmpData[12],rBmpData[11],rBmpData[10]};
	
	//关闭输入BMP图片
	$fclose(iBmpFileId);
	// if((iBmpWidth!= IMG_HDISP) | (iBmpHight!=IMG_VDISP)) begin
	// 	$display("Resolution mismatching.\n");
	// 	$stop;
	// end
end

//---------------------------------------------
//产生摄像头时序 

wire		cmos_vsync ;
reg			cmos_href;
wire        cmos_clken;
reg	[23:0]	cmos_data;	
		 
reg         cmos_clken_r;

reg [31:0]  cmos_index;

localparam H_SYNC = 11'd10;		
localparam H_BACK = 11'd10;		
localparam H_DISP = IMG_HDISP;	
localparam H_FRONT = 11'd10;		
localparam H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;	

localparam V_SYNC = 11'd10;		
localparam V_BACK = 11'd10;		
localparam V_DISP = IMG_VDISP;	
localparam V_FRONT = 11'd10;		
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
		cmos_vsync_r <= 1'b0;		//H: Vaild, L: inVaild
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
       cmos_index   <=  y_pos * IMG_HDISP * 3  + x_pos * 3 + 54;         //  3*(y*640 + x) + 54
       cmos_data    <=  {rBmpData[cmos_index], rBmpData[cmos_index+1] , rBmpData[cmos_index+2]};
   end
end
 
reg [10:0] x_pos_d	[0 : 10];
reg [10:0] y_pos_d	[0 : 10];

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(i = 0; i < 11; i = i + 1)begin
			x_pos_d[i]	<=	0;
			y_pos_d[i]	<=	0;
		end	
	end
	else begin
		x_pos_d[0]	<=	x_pos;
		y_pos_d[0]	<=	y_pos;
		for(i = 1; i < 11; i = i + 1)begin
			x_pos_d[i]	<=	x_pos_d[i-1];
			y_pos_d[i]	<=	y_pos_d[i-1];
		end	
	end
end

assign		CMOS_VSYNC		=	cmos_vsync;
assign		CMOS_HREF		=	cmos_href;
assign		CMOS_CLKEN		=	cmos_clken;
assign		CMOS_DATA		=	cmos_data;
assign		X_POS			=	x_pos;
assign		Y_POS			=	y_pos;


endmodule