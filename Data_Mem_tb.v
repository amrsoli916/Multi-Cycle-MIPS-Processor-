module Data_Mem_tb();
reg clk,rst,we;
reg [31:0]a,wd;
wire [31:0]rd;
Data_Mem dut(.clk(clk),.rst(rst),.we(we),.a(a),.wd(wd),.rd(rd));
initial begin
    clk=0;
    forever #1 clk=~clk;
end
initial begin
    $readmemh("Data_Mem.mem",dut.datmem);
    rst=1;we=0;a=0;wd=0;
    @(negedge clk);
    rst=0;
    repeat(50) begin
        @(negedge clk);
        a=$random%256;
        wd=$random;
        we=$random;
    end
    $stop;
end
endmodule