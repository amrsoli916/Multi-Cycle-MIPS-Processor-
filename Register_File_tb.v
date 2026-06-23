module Register_File_tb();
reg clk,rst,we3;
reg [4:0]a1,a2,a3;
reg [31:0]wd3;
wire [31:0]rd1,rd2;
Register_File RF(.clk(clk),.rst(rst),.a1(a1),.a2(a2),.a3(a3),
.wd3(wd3),.we3(we3),.rd1(rd1),.rd2(rd2));
initial begin
    clk=0;
    forever #1 clk=~clk;
end
initial begin
    $readmemh("Register_File.mem",RF.regfile);
    rst=1;we3=0;a1=0;a2=0;a3=0;wd3=0;
    @(negedge clk);
    rst=0;
    repeat(50) begin
        @(negedge clk);
        a1=$random%32;
        a2=$random%32;
        a3=$random%32;
        wd3=$random;
        we3=$random;
    end
    $stop;
end
endmodule