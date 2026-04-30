module control_tb();

reg clk;
reg rst;
reg [5:0] Op,Funct;    
wire PCWrite,Branch,ALUSrcA,RegWrite,IorD,MemWrite,IRWrite,RegDst,MemtoReg;
wire [3:0] ALUControl; 
wire [1:0] ALUSrcB,PCSrc;

//instatniate control unit
control_unit control_unit_inst(
    .clk(clk),
    .rst(rst),
    .Op(Op),
    .Funct(Funct),
    .PCWrite(PCWrite),
    .Branch(Branch),
    .ALUSrcA(ALUSrcA),
    .RegWrite(RegWrite),
    .IorD(IorD),
    .MemWrite(MemWrite),
    .IRWrite(IRWrite),
    .RegDst(RegDst),
    .MemtoReg(MemtoReg),
    .ALUControl(ALUControl),
    .ALUSrcB(ALUSrcB),
    .PCSrc(PCSrc)
);

//generate clock
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns clock period
end

//test the state 
initial begin
    rst = 1;
    @(posedge clk);
    rst = 0;
    @(posedge clk);
    Op = 6'b100011; // lw
    Funct = 6'b000000; // not used for lw
    repeat (4) @(posedge clk);

    Op = 6'b101011; // sw
    Funct = 6'b000000; // not used for sw
    repeat (4) @(posedge clk);

    Op = 6'b001000; // addi
    Funct = 6'b000000; // not used for addi
    repeat (4) @(posedge clk);    

    Op = 6'b000100; // beq
    Funct = 6'b000000; // not used for beq
    repeat (3) @(posedge clk);

    Op = 6'b000010; // jump
    Funct = 6'b000000; // not used for jump
    repeat (3) @(posedge clk);

    Op = 6'b000000; // R-type
    Funct = 6'b100000; // add
    repeat (4) @(posedge clk);

    Op = 6'b000000; // R-type
    Funct = 6'b100010; // sub
    repeat (4) @(posedge clk);   

    Op = 6'b000000; // R-type
    Funct = 6'b101010; // slt
    repeat (4) @(posedge clk);   

    Op = 6'b000000; // R-type
    Funct = 6'b100111; //nor
    repeat (4) @(posedge clk);  

    $stop; // stop the simulation
end

endmodule