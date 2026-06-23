module register(in,out,clk,en,rst);
input [31:0] in;
output reg [31:0] out;
input clk,en,rst;
always @(posedge clk) begin
    if (rst)
        out <= 0;
    else if (en)
        out <= in;
end
endmodule