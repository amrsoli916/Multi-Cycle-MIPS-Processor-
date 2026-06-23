module Data_Mem(clk,rst,we,a,wd,rd);
input clk,rst,we;
input [31:0]a,wd;
output reg [31:0]rd;
reg [31:0]datmem[0:255];
always@(posedge clk) begin
    if(we)
    datmem[a[7:0]]<=wd;
end
always@(*) begin
    if(rst)
    rd=32'b0;
    else
    rd=datmem[a[7:0]];
end
endmodule