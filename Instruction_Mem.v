module Instruction_Mem(rst,a,rd);
input rst;
input [31:0]a;
output reg [31:0]rd;
reg [31:0]insmem[0:255];
initial begin
    $readmemh("Instruction_Mem.mem",insmem);
end
always@(*) begin
    if(rst)
    rd=32'b0;
    else
    rd=insmem[a[9:2]];
end
endmodule