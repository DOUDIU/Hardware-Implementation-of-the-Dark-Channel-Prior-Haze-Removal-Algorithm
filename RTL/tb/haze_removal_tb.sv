`timescale 1ns / 1ps
module haze_removal_tb();

`define Modelsim_Sim
// `define Vivado_Sim

//--------------------------------------------------------------------------------
`ifdef Modelsim_Sim
localparam	PIC_INPUT_PATH  	= 	"..\\pic\\duck.bmp"			;
localparam	PIC_OUTPUT_PATH 	= 	"..\\pic\\outcom.bmp"  		;
`endif
//--------------------------------------------------------------------------------
`ifdef Vivado_Sim
localparam	PIC_INPUT_PATH  	= 	"../../../../../pic/duck.bmp"			;
localparam	PIC_OUTPUT_PATH 	= 	"../../../../../pic/outcom.bmp"  		;
`endif

localparam	PIC_WIDTH  			=	640							;
localparam	PIC_HEIGHT 			=	480 						;

reg         cmos_clk   = 0;
reg         cmos_rst_n = 0;

wire        cmos_vsync              ;
wire        cmos_href               ;
wire        cmos_clken              ;
wire [23:0] cmos_data               ;

wire        haze_removal_vsync      ;
wire        haze_removal_hsync      ;
wire        haze_removal_de         ;
wire [23:0] haze_removal_data       ;

parameter cmos0_period = 6;

always#(cmos0_period/2) cmos_clk = ~cmos_clk;
initial #(20*cmos0_period) cmos_rst_n = 1;

//--------------------------------------------------
//Camera Simulation
sim_cmos #(
		.PIC_PATH		(PIC_INPUT_PATH			)
	,	.IMG_HDISP 		(PIC_WIDTH 				)
	,	.IMG_VDISP 		(PIC_HEIGHT				)
)u_sim_cmos0(
        .clk            (cmos_clk	    		)
    ,   .rst_n          (cmos_rst_n     		)
	,   .CMOS_VSYNC     (cmos_vsync     		)
	,   .CMOS_HREF      (cmos_href      		)
	,   .CMOS_CLKEN     (cmos_clken     		)
	,   .CMOS_DATA      (cmos_data      		)
	,   .X_POS          ()
	,   .Y_POS          ()
);

//--------------------------------------------------
//Image Processing
haze_removal_top #(
	 	.Y_ENHANCE_ENABLE	(0						)
	,	.PIC_WIDTH			(PIC_WIDTH				)
)u_haze_removal_top(
		.clk               	(cmos_clk	            )
	,	.rst_n             	(cmos_rst_n             )
	//处理前数据	
	,	.pre_frame_vsync   	(cmos_vsync             )
	,	.pre_frame_href    	(cmos_href              )
	,	.pre_frame_clken   	(cmos_clken             )
	,	.pre_img           	(cmos_data              )
	//处理后的数据
	,	.post_frame_vsync  	(haze_removal_vsync		)
	,	.post_frame_href   	(haze_removal_hsync		)
	,	.post_frame_clken  	(haze_removal_de   		)
	,	.post_img          	(haze_removal_data      )
);

//--------------------------------------------------
//Video saving 
video_to_pic #(
		.PIC_PATH       (PIC_OUTPUT_PATH		)
	,	.START_FRAME    (2                      )
	,	.IMG_HDISP      (PIC_WIDTH 				)
	,	.IMG_VDISP      (PIC_HEIGHT				)
)u_video_to_pic0(
	 	.clk            (cmos_clk	            )
	,	.rst_n          (cmos_rst_n             )
	,	.video_vsync    (haze_removal_vsync		)
	,	.video_hsync    (haze_removal_hsync		)
	,	.video_de       (haze_removal_de   		)
	,	.video_data     (haze_removal_data      )
);







endmodule