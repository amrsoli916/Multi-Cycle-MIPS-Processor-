module SignExtend(instr,signimm);
input [15:0]instr;
output [31:0]signimm;
assign signimm={{16{instr[15]}},instr};
endmodule