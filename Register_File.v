module Register_File(clk,rst,a1,a2,a3,wd3,we3,rd1,rd2);
    input clk,rst,we3;
    input [4:0]a1,a2,a3;
    input [31:0]wd3;
    output reg [31:0]rd1,rd2;
    reg [31:0]regfile[0:31];
    always@(posedge clk) begin
            if(we3)
            regfile[a3]<=wd3;
        end
    always @(*) begin
        if(rst)
        begin
            rd1=32'b0;
            rd2=32'b0;
        end    
        else
        begin
            rd1=regfile[a1];
            rd2=regfile[a2];
            end
    end
endmodule