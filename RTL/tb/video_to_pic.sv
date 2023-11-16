`timescale 1ns / 1ns
module video_to_pic#(
        parameter PIC_PATH = "..\\pic\\outcom.bmp"
    ,   parameter START_FRAME   = 1
	,	parameter IMG_HDISP     = 640
	,	parameter IMG_VDISP     = 480
)(
        input                       clk
    ,   input                       rst_n
    ,   input                       video_vsync
    ,   input                       video_hsync
    ,   input                       video_de
    ,   input   [23:0]              video_data
);

integer iCode;
integer iBmpFileId;             
integer iBmpWidth;              
integer iBmpHight;              
integer iBmpSize;               
integer iDataStartIndex;        
integer iIndex = 0;

localparam BMP_SIZE   = 54 + IMG_HDISP * IMG_VDISP * 3 - 1;  
reg [ 7:0] BmpHead          [0:53];
reg [ 7:0] Vip_BmpData      [0:BMP_SIZE]; 
reg [ 7:0] vip_pixel_data   [0:BMP_SIZE-54];
reg [31:0] rBmpWord;

reg             video_vsync_d1 = 0;
reg     [11:0]  frame_cnt = 0;
reg     [31:0]  PIC_cnt = 0;

wire    [7:0]   PIC_img_R;
wire    [7:0]   PIC_img_G;
wire    [7:0]   PIC_img_B;
assign          PIC_img_R = video_data[16+:8];
assign          PIC_img_G = video_data[ 8+:8];
assign          PIC_img_B = video_data[ 0+:8];


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        video_vsync_d1   <=  0;
    end
    else begin
        video_vsync_d1  <=  video_vsync;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        frame_cnt   <=  0;
    end
    else if(video_vsync_d1 & !video_vsync)begin
        frame_cnt   <=  frame_cnt + 1;
    end
end



always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        PIC_cnt <=  32'd0;
   end
   else if(video_de) begin
        if(frame_cnt == START_FRAME - 1) begin
            PIC_cnt                     <=  PIC_cnt + 3;
            vip_pixel_data[PIC_cnt+0]   <=  PIC_img_R;
            vip_pixel_data[PIC_cnt+1]   <=  PIC_img_G;
            vip_pixel_data[PIC_cnt+2]   <=  PIC_img_B;
        end
   end
end


//---------------------------------------------	
//initial the BMP file header
//The detail BMP file header is inpart from https://blog.csdn.net/Meteor_s/article/details/82414155 and inpart from my test. 
initial begin
    for(iIndex = 0; iIndex < 54; iIndex = iIndex + 1) begin
        BmpHead[iIndex] = 0;
    end
    #2
    {BmpHead[1],BmpHead[0]} = {8'h4D,8'h42};
    {BmpHead[5],BmpHead[4],BmpHead[3],BmpHead[2]} = BMP_SIZE + 1;//File Size (Bytes)
    BmpHead[10] = 8'd54;//Bitmap Data Offset
    BmpHead[14] = 8'h28;//Bitmap Header Size
    {BmpHead[21],BmpHead[20],BmpHead[19],BmpHead[18]} = IMG_HDISP;//Width
    {BmpHead[25],BmpHead[24],BmpHead[23],BmpHead[22]} = IMG_VDISP;//Height
    BmpHead[26] = 8'd1;//Number of Color Planes
    BmpHead[28] = 8'd24;//Bits per Pixel
end



//---------------------------------------------	
//write the data to the output bmp file
initial begin    
//---------------------------------------------	
//waiting for the start frame
    wait(frame_cnt == START_FRAME);
    
    iBmpFileId = $fopen(PIC_PATH,"wb+");
    for (iIndex = 0; iIndex < BMP_SIZE + 1; iIndex = iIndex + 1) begin
        if(iIndex < 54) begin
            Vip_BmpData[iIndex] = BmpHead[iIndex];
        end
        else begin
            Vip_BmpData[iIndex] = vip_pixel_data[iIndex-54];
        end
    end  
    for (iIndex = 0; iIndex < BMP_SIZE + 1; iIndex = iIndex + 1) begin
        $fwrite(iBmpFileId,"%c",Vip_BmpData[iIndex]);
    end
    $fclose(iBmpFileId);
end




endmodule