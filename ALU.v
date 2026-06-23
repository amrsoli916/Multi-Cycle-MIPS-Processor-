module ALU(srca,srcb,alu_control,alu_result,zero);
input [31:0]srca,srcb;
input [3:0]alu_control;
output reg [31:0]alu_result;
output zero;
assign zero = (alu_result == 0);
always @(*) begin
    case(alu_control)
        4'b0000: alu_result = srca & srcb; // AND
        4'b0001: alu_result = srca | srcb; // OR
        4'b0010: alu_result = srca + srcb; // ADD
        4'b0110: alu_result = srca - srcb; // SUB
        4'b0111: alu_result = (srca < srcb) ? 32'b1 : 32'b0; // SLT
        4'b1100: alu_result = ~(srca | srcb); // NOR
        default: alu_result = 32'b0;
    endcase
end
endmodule