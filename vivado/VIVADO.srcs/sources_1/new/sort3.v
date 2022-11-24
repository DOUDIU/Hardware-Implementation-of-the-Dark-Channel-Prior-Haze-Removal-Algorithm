module sort3(
    input            clk,
    input            rst_n,
    input [7:0]      data1, 
    input [7:0]      data2, 
    input [7:0]      data3,
    
    output reg [7:0] max_data, 
    output reg [7:0] mid_data, 
    output reg [7:0] min_data
);

//-----------------------------------
//���������ݽ�������
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        max_data <= 0;
        mid_data <= 0;
        min_data <= 0;
    end
    else begin
        //ȡ���ֵ
        if(data1 >= data2 && data1 >= data3)
            max_data <= data1;
        else if(data2 >= data1 && data2 >= data3)
            max_data <= data2;
        else//(data3 >= data1 && data3 >= data2)
            max_data <= data3;
        //ȡ��ֵ
        if((data1 >= data2 && data1 <= data3) || (data1 >= data3 && data1 <= data2))
            mid_data <= data1;
        else if((data2 >= data1 && data2 <= data3) || (data2 >= data3 && data2 <= data1))
            mid_data <= data2;
        else//((data3 >= data1 && data3 <= data2) || (data3 >= data2 && data3 <= data1))
            mid_data <= data3;
        //ȡ��Сֵ
        if(data1 <= data2 && data1 <= data3)
            min_data <= data1;
        else if(data2 <= data1 && data2 <= data3)
            min_data <= data2;
        else//(data3 <= data1 && data3 <= data2)
            min_data <= data3;
        
     end
end

endmodule 