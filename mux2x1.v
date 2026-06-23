module mux2x1(in0,in1,s,out);
input [31:0] in0,in1;
input s;
output reg [31:0] out;
always @(*) begin
    if (s)
        out = in1;
    else
        out = in0;
end
endmodule