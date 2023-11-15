
`timescale    1ns/1ps
module YCbCr2RGB
(
    input                             	i_sys_clk           ,

	input								i_vs				,
	input								i_hs				,
    input                             	i_convert_en        ,
    input            [7:0]            	i_y_data            ,
    input            [7:0]            	i_cr_data           ,
    input            [7:0]            	i_cb_data           ,


	output								o_vs				,
	output								o_hs				,
    output                             	o_convert_en        ,
    output    reg    [7:0]            	o_red               ,
    output    reg    [7:0]            	o_green             ,
    output    reg    [7:0]            	o_blue
);

reg		i_vs_d1;
reg		i_vs_d2;
reg		i_vs_d3;


reg		i_hs_d1;
reg		i_hs_d2;
reg		i_hs_d3;


reg		i_convert_en_d1;
reg		i_convert_en_d2;
reg		i_convert_en_d3;

always@(posedge i_sys_clk)begin

	i_vs_d1 <= i_vs;
	i_vs_d2 <= i_vs_d1;
	i_vs_d3 <= i_vs_d2;

	i_hs_d1 <= i_hs;
	i_hs_d2 <= i_hs_d1;
	i_hs_d3 <= i_hs_d2;

	i_convert_en_d1 <= i_convert_en;
	i_convert_en_d2 <= i_convert_en_d1;
	i_convert_en_d3 <= i_convert_en_d2;
end

assign o_vs = i_vs_d3;
assign o_hs = i_hs_d3;
assign o_convert_en = i_convert_en_d3;

    reg            [7:0]             r_y_data         ;
    reg            [7:0]             r_cb_data        ;
    reg            [7:0]             r_cr_data        ;
    reg            [32:0]            r_r_ypart        ;
    reg            [32:0]            r_r_crpart       ;
    reg            [32:0]            r_g_ypart        ;
    reg            [32:0]            r_g_crpart       ;
    reg            [32:0]            r_g_cbpart       ;
    reg            [32:0]            r_b_ypart        ;
    reg            [32:0]            r_b_cbpart       ;
    reg            [32:0]            r_r_sum          ;
    reg            [32:0]            r_g_sum          ;
    reg            [32:0]            r_b_sum          ;

    always@(posedge i_sys_clk)
    begin
        if(i_convert_en)
        begin
            r_y_data  <= i_y_data;
            r_cr_data <= i_cr_data;
            r_cb_data <= i_cb_data;
        end
    end
/******************************************************************************\
RGB(i, j,1) =Y1(i,j)+1.371*(Cr0(i,j)-128);
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(i_convert_en)
        begin
            r_r_crpart <= 10'd380 * i_cr_data;     //0.594*1024 = 610
            r_r_sum    <= ((r_y_data + r_cr_data)<<10) + r_r_crpart - 179700;
        end
    end
/******************************************************************************\
RGB(i, j,2) =Y1(i,j)-0.689*(Cr0(i,j)-128)-0.336*(Cb0(i,j)-128);
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(i_convert_en)
        begin   
            r_g_crpart <= 10'd706 * i_cr_data;   
            r_g_cbpart <= 10'd344 * i_cb_data;   
            r_g_sum    <= (r_y_data << 10) - r_g_crpart - r_g_cbpart + 134349;
        end
    end
/******************************************************************************\
RGB(i, j,3) =Y1(i,j)+1.732*(Cb0(i,j)-128);
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(i_convert_en)
        begin
            r_b_cbpart <= 10'd750  * i_cb_data;    
            r_b_sum    <= (r_y_data << 10) + (r_cb_data << 10) + r_b_cbpart - 227017;
        end
    end
/******************************************************************************\
output R
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(i_convert_en) begin
			if(r_r_sum[31:10]>255)begin
                o_red <= 8'hff;
            end
            else
            begin
                o_red <= r_r_sum[31:10];
            end
        end
    end
/******************************************************************************\
output G
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(i_convert_en)
        begin if(r_g_sum[31:10]>255)
            begin
                o_green <= 8'hff;
            end
            else
            begin
                o_green <= r_g_sum[31:10];
            end
        end
    end
/******************************************************************************\
output B
\******************************************************************************/
    always@(posedge i_sys_clk)
    begin
        if(i_convert_en)
        begin
            if(r_b_sum[31:10]>255)
            begin
                o_blue <= 8'hff;
            end
            else
            begin
                o_blue <= r_b_sum[31:10];
            end
        end
    end

endmodule