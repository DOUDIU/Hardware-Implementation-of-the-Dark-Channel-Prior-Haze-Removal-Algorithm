module cordic_sqrt#(
    parameter DATA_WIDTH_IN     =   11,
    parameter DATA_WIDTH_OUT    =   22,
    parameter Pipeline          =   8
)(
    input                                       clk,
    input                                       rst_n,
    input           [DATA_WIDTH_IN - 1 : 0]     sqrt_in_0,
    input           [DATA_WIDTH_IN - 1 : 0]     sqrt_in_1,

    output          [DATA_WIDTH_OUT - 1: 0]     sqrt_out,
    output          [6 : 0]                     angle_out
);


parameter rot0  = 32'd2949120;       //45業*2^16
parameter rot1  = 32'd1740992;       //26.5651業*2^16
parameter rot2  = 32'd919872 ;       //14.0362業*2^16
parameter rot3  = 32'd466944 ;       //7.1250業*2^16
parameter rot4  = 32'd234368 ;       //3.5763業*2^16
parameter rot5  = 32'd117312 ;       //1.7899業*2^16
parameter rot6  = 32'd58688  ;       //0.8952業*2^16
parameter rot7  = 32'd29312  ;       //0.4476業*2^16
parameter rot8  = 32'd14656  ;       //0.2238業*2^16
parameter rot9  = 32'd7360   ;       //0.1119業*2^16
parameter rot10 = 32'd3648   ;       //0.0560業*2^16
parameter rot11 = 32'd1856   ;       //0.0280業*2^16
parameter rot12 = 32'd896    ;       //0.0140業*2^16
parameter rot13 = 32'd448    ;       //0.0070業*2^16
parameter rot14 = 32'd256    ;       //0.0035業*2^16
parameter rot15 = 32'd128    ;       //0.0018業*2^16

parameter K = 32'h09b74;    //K=0.607253*2^16,32'h09b74,

wire     signed [DATA_WIDTH_IN - 1 : 0]     x[15 : 0];
wire     signed [DATA_WIDTH_IN - 1 : 0]     y[15 : 0];
wire            [31 : 0]                    rot_out[15 : 0];

assign      x[0]    =   sqrt_in_0;
assign      y[0]    =   sqrt_in_1;

cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_0 (.clk(clk),.rst_n(rst_n),.x_in(x[0 ]),.y_in(y[0 ]),.polar_flag(y[0 ] > 0),.pipline_level(0 ),.x_out(x[1 ]),.y_out(y[1 ]),.rot_in(32'd0      ),.rot_out(rot_out[0 ]),.rot(rot0 ));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_1 (.clk(clk),.rst_n(rst_n),.x_in(x[1 ]),.y_in(y[1 ]),.polar_flag(y[1 ] > 0),.pipline_level(1 ),.x_out(x[2 ]),.y_out(y[2 ]),.rot_in(rot_out[0 ]),.rot_out(rot_out[1 ]),.rot(rot1 ));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_2 (.clk(clk),.rst_n(rst_n),.x_in(x[2 ]),.y_in(y[2 ]),.polar_flag(y[2 ] > 0),.pipline_level(2 ),.x_out(x[3 ]),.y_out(y[3 ]),.rot_in(rot_out[1 ]),.rot_out(rot_out[2 ]),.rot(rot2 ));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_3 (.clk(clk),.rst_n(rst_n),.x_in(x[3 ]),.y_in(y[3 ]),.polar_flag(y[3 ] > 0),.pipline_level(3 ),.x_out(x[4 ]),.y_out(y[4 ]),.rot_in(rot_out[2 ]),.rot_out(rot_out[3 ]),.rot(rot3 ));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_4 (.clk(clk),.rst_n(rst_n),.x_in(x[4 ]),.y_in(y[4 ]),.polar_flag(y[4 ] > 0),.pipline_level(4 ),.x_out(x[5 ]),.y_out(y[5 ]),.rot_in(rot_out[3 ]),.rot_out(rot_out[4 ]),.rot(rot4 ));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_5 (.clk(clk),.rst_n(rst_n),.x_in(x[5 ]),.y_in(y[5 ]),.polar_flag(y[5 ] > 0),.pipline_level(5 ),.x_out(x[6 ]),.y_out(y[6 ]),.rot_in(rot_out[4 ]),.rot_out(rot_out[5 ]),.rot(rot5 ));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_6 (.clk(clk),.rst_n(rst_n),.x_in(x[6 ]),.y_in(y[6 ]),.polar_flag(y[6 ] > 0),.pipline_level(6 ),.x_out(x[7 ]),.y_out(y[7 ]),.rot_in(rot_out[5 ]),.rot_out(rot_out[6 ]),.rot(rot6 ));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_7 (.clk(clk),.rst_n(rst_n),.x_in(x[7 ]),.y_in(y[7 ]),.polar_flag(y[7 ] > 0),.pipline_level(7 ),.x_out(x[8 ]),.y_out(y[8 ]),.rot_in(rot_out[6 ]),.rot_out(rot_out[7 ]),.rot(rot7 ));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_8 (.clk(clk),.rst_n(rst_n),.x_in(x[8 ]),.y_in(y[8 ]),.polar_flag(y[8 ] > 0),.pipline_level(8 ),.x_out(x[9 ]),.y_out(y[9 ]),.rot_in(rot_out[7 ]),.rot_out(rot_out[8 ]),.rot(rot8 ));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_9 (.clk(clk),.rst_n(rst_n),.x_in(x[9 ]),.y_in(y[9 ]),.polar_flag(y[9 ] > 0),.pipline_level(9 ),.x_out(x[10]),.y_out(y[10]),.rot_in(rot_out[8 ]),.rot_out(rot_out[9 ]),.rot(rot9 ));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_10(.clk(clk),.rst_n(rst_n),.x_in(x[10]),.y_in(y[10]),.polar_flag(y[10] > 0),.pipline_level(10),.x_out(x[11]),.y_out(y[11]),.rot_in(rot_out[9 ]),.rot_out(rot_out[10]),.rot(rot10));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_11(.clk(clk),.rst_n(rst_n),.x_in(x[11]),.y_in(y[11]),.polar_flag(y[11] > 0),.pipline_level(11),.x_out(x[12]),.y_out(y[12]),.rot_in(rot_out[10]),.rot_out(rot_out[11]),.rot(rot11));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_12(.clk(clk),.rst_n(rst_n),.x_in(x[12]),.y_in(y[12]),.polar_flag(y[12] > 0),.pipline_level(12),.x_out(x[13]),.y_out(y[13]),.rot_in(rot_out[11]),.rot_out(rot_out[12]),.rot(rot12));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_13(.clk(clk),.rst_n(rst_n),.x_in(x[13]),.y_in(y[13]),.polar_flag(y[13] > 0),.pipline_level(13),.x_out(x[14]),.y_out(y[14]),.rot_in(rot_out[12]),.rot_out(rot_out[13]),.rot(rot13));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_14(.clk(clk),.rst_n(rst_n),.x_in(x[14]),.y_in(y[14]),.polar_flag(y[14] > 0),.pipline_level(14),.x_out(x[15]),.y_out(y[15]),.rot_in(rot_out[13]),.rot_out(rot_out[14]),.rot(rot14));
cordic_pipline#(.DATA_WIDTH_IN(DATA_WIDTH_IN),.Pipeline(Pipeline))u_cordic_pipline_15(.clk(clk),.rst_n(rst_n),.x_in(x[15]),.y_in(y[15]),.polar_flag(y[15] > 0),.pipline_level(15),.x_out(x[16]),.y_out(y[16]),.rot_in(rot_out[14]),.rot_out(rot_out[15]),.rot(rot15));

assign  sqrt_out    = x[Pipeline - 1] * K >> 16;
assign  angle_out   = rot_out[Pipeline - 1] >> 16;

endmodule
