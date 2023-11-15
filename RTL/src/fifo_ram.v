module fifo_ram#(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 640
)
(
    input                               clk,
    //write port
    input                               wr_en,
    input       [DATA_WIDTH - 1 : 0]    wr_data,
    output                              wr_full,
    //read port
    input                               rd_en,
    output reg  [DATA_WIDTH - 1 : 0]    rd_data,
    output                              rd_empty
);
    //define ram
    (*ram_style = "block" *) reg [DATA_WIDTH - 1 : 0] fifo_buffer[DATA_DEPTH - 1 : 0];

    integer i;
    initial begin
        for(i = 0;i<DATA_DEPTH;i = i + 1)begin
            fifo_buffer[i] <=  0;
        end
    end

    reg     [$clog2(DATA_DEPTH) - 1 : 0]    wr_pointer = 0;//form end to read data
    reg     [$clog2(DATA_DEPTH) - 1 : 0]    rd_pointer = 0;
    wire    [DATA_WIDTH - 1 : 0]            rd_data_out;

//keep track of the write  pointer
always @(posedge clk) begin
    if (wr_en) begin
        if (wr_pointer == DATA_DEPTH - 1) begin
            wr_pointer <= 0; 
        end
        else begin
            wr_pointer <= wr_pointer + 1;
        end
    end
end

//keep track of the read pointer 
always @(posedge clk) begin
    if (rd_en) begin
        if (rd_pointer == DATA_DEPTH - 1) begin
            rd_pointer <= 0;
        end
        else begin
            rd_pointer <= rd_pointer + 1;
        end
    end
end

//write data into fifo when wr_en is asserted
always @(posedge clk) begin
    if (wr_en) begin
        fifo_buffer[wr_pointer] <= wr_data;
    end
end

assign rd_data_out = rd_en ? fifo_buffer[rd_pointer] : 0;
    
always @(posedge clk) begin
    rd_data <=  rd_data_out;//ясЁыр╩ед
end


endmodule