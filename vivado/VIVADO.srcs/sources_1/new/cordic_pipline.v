module cordic_pipline#(
    parameter DATA_WIDTH_IN     =   11,
    parameter Pipeline          =   16
)(
    input                                               clk,
    input                                               rst_n,
    input           signed  [DATA_WIDTH_IN - 1 : 0]     x_in,
    input           signed  [DATA_WIDTH_IN - 1 : 0]     y_in,
    input                                               polar_flag,
    input                   [5  : 0]                    pipline_level,
    input                   [31 : 0]                    rot,
    input                   [31 : 0]                    rot_in,
    
    output  reg             [31 : 0]                    rot_out,
    output  reg     signed  [DATA_WIDTH_IN - 1 : 0]     x_out,
    output  reg     signed  [DATA_WIDTH_IN - 1 : 0]     y_out
);


always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        x_out    <=      0;                         
        y_out    <=      0;
    end
    else begin
        if(polar_flag)begin
            x_out       <=      x_in + (y_in >>> pipline_level);                         
            y_out       <=      y_in - (x_in >>> pipline_level);
            rot_out     <=      rot_in + rot;     
        end
        else begin
            x_out       <=      x_in - (y_in >>> pipline_level);                         
            y_out       <=      y_in + (x_in >>> pipline_level);
            rot_out     <=      rot_in - rot;     
        end
    end
end


endmodule
