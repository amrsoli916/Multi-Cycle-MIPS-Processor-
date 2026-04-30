module control_unit(clk,rst,Op,Funct,PCWrite,Branch,PCSrc,ALUControl,ALUSrcB,ALUSrcA,RegWrite
                        ,IorD,MemWrite,IRWrite,RegDst,MemtoReg);

parameter        Fetch = 4'b0000;       //State to Calculate the New Pc and Fetch the Past Instruction
parameter       Decode = 4'b0001;       //State to wait & here calculate the new PC for Brunch   
parameter       MemAdr = 4'b0010;       //State if Lw or Sw or Addi to take immidiate from instr[15:0]
parameter      MemRead = 4'b0011;       //if Lw -> wait to take the value from AluOut reg 
parameter MemWriteback = 4'b0100;       //write this value from last state to the register
parameter     memWrite = 4'b0101;       //if Sw -> write the value from rigester to memory
parameter      Execute = 4'b0110;       //if R-type calculate the instruction
parameter AluWriteback = 4'b0111;       // write the rwsult in the register
parameter       branch = 4'b1000;       //if Brunch -> sub to value if equal wirte the calculation value from Decode to Pc
parameter AddiWriteback = 4'b1001;      //if Addi -> after MemAdr state write the calculation value to the register
parameter          jump = 4'b1010;      //if Jump -> take the address of Jump and write to the Pc

reg [3:0] cs,ns;     // internal signal to switch between State

input clk,rst;        // clock and reset signal
input [5:0] Op,Funct;  // opcode and function from the instruction
output reg PCWrite,Branch,ALUSrcA,RegWrite,IorD,MemWrite,IRWrite,RegDst,MemtoReg;
output reg [3:0] ALUControl; 
output reg [1:0] ALUSrcB,PCSrc;

//Next State Logic
always @(*) begin
   casex (cs)
    Fetch : begin
        ns = Decode;
    end

    Decode : begin
        case (Op)
            6'b100011: ns = MemAdr; // lw
            6'b101011: ns = MemAdr; // sw
            6'b001000: ns = MemAdr; // addi

            6'b000000 : begin
                ns = Execute;  // if instruction is R-type -> ns = Execute
            end
            6'b000100 : begin
                ns = branch;   // if instruction is Brunch -> ns = Brunch
            end
            6'b000010 : begin
                ns = jump;     // if instruction is jump -> ns = Jump
            end
            default: ns = Fetch;   // if take unknown instruction Back to the Fetch
        endcase
    end

    MemAdr : begin
        case (Op)
           6'b100011 : begin
               ns = MemRead;      // if instruction is Lw 
           end
           6'b101011 : begin
                ns = memWrite;    // if instruction is Sw
           end
           6'b001000 : begin
                ns = AddiWriteback;    // if instruction is Addi
           end
            default: ns = Fetch;      // if take unknown instruction back to the Fetch
        endcase
    end

    MemRead : begin
        ns = MemWriteback;   // if state is MemRead the next state is MemWriteback
    end  

    MemWriteback : begin
        ns = Fetch;        // if state is MemWriteback the next state is the fetch , finish LW instruction
    end  

    memWrite : begin
        ns = Fetch;       // if state is the MemWrite the next state is the Fetch , finish Sw instruction
    end

    Execute : begin
        ns = AluWriteback;   //if state is Execute next state is the AluWriteback to write the value in the register
    end

    AluWriteback : begin
        ns = Fetch;         // if state is AluWriteback next state is the Fetch , finish the R-type instruction 
    end

    branch : begin
        ns = Fetch;         // if state is Branch next state is Fetch , finish the brunch instruction 
    end

    AddiWriteback : begin
        ns = Fetch;         // if state is AddiWriteback next state is Fetch , finish the brunch instruction  
    end

    jump : begin
        ns = Fetch;         // if state is Jump next state is Fetch , finish the brunch instruction 
    end
    default: ns = Fetch;      //if take unknown instruction back to the fetch state 
   endcase
end

//state memory 
always @(posedge clk) begin
    if (rst) begin
        cs <=  Fetch;          // if reset the control back to the fetch state 
    end
    else begin
        cs <= ns;              // else cs take from ns 
    end    
end

//output logic
always @(*) begin
    casex (cs)
       Fetch : begin
        PCWrite = 1; Branch = 0; PCSrc = 2'b00;
        ALUSrcA = 0; RegWrite = 0; IorD = 0;
        MemWrite = 0; IRWrite = 1; RegDst = 0; MemtoReg = 0;
        ALUControl = 4'b0010; ALUSrcB = 2'b01; 
       end

       Decode : begin
        PCWrite = 0; Branch = 0; PCSrc = 2'b00;
        ALUSrcA = 0; RegWrite = 0; IorD = 0;
        MemWrite = 0; IRWrite = 0; RegDst = 0;
        MemtoReg = 0; ALUControl = 4'b0010; ALUSrcB = 2'b11; 
       end    

       MemAdr : begin
        PCWrite = 0; Branch = 0; PCSrc = 2'b00;
        ALUSrcA = 1; RegWrite = 0; IorD = 0;
        MemWrite = 0; IRWrite = 0; RegDst = 0;
        MemtoReg = 0; ALUControl = 4'b0010; ALUSrcB = 2'b10; 
       end          

       MemRead : begin
        PCWrite = 0; Branch = 0; PCSrc = 2'b00;
        ALUSrcA = 1; RegWrite = 0; IorD = 1;
        MemWrite = 0; IRWrite = 0; RegDst = 0;
        MemtoReg = 0; ALUControl = 4'b0010; ALUSrcB = 2'b10; 
       end

       MemWriteback : begin
        PCWrite = 0; Branch = 0; PCSrc = 2'b00;
        ALUSrcA = 1; RegWrite = 1; IorD = 0;
        MemWrite = 0; IRWrite = 0; RegDst = 0;
        MemtoReg = 1; ALUControl = 4'b0010; ALUSrcB = 2'b10; 
       end   

       memWrite : begin
        PCWrite = 0; Branch = 0; PCSrc = 2'b00;
        ALUSrcA = 1; RegWrite = 0; IorD = 1;
        MemWrite = 1; IRWrite = 0; RegDst = 0;
        MemtoReg = 0; ALUControl = 4'b0010; ALUSrcB = 2'b10; 
       end  

       Execute : begin
        PCWrite = 0; Branch = 0; PCSrc = 2'b00;
        ALUSrcA = 1; RegWrite = 0; IorD = 0;
        MemWrite = 0; IRWrite = 0; RegDst = 0;
        MemtoReg = 0; ALUSrcB = 2'b00; 
        casex (Funct) 
            6'bxx0000 : ALUControl = 4'b0010; // add
            6'bxx0010 : ALUControl = 4'b0110; // sub
            6'bxx0100 : ALUControl = 4'b0000; // and
            6'bxx0101 : ALUControl = 4'b0001; // or
            6'bxx1010 : ALUControl = 4'b0111; // slt
            6'bxx0111 : ALUControl = 4'b1100; // nor
            default: ALUControl = 4'b0000; 
        endcase
       end  

       AluWriteback : begin
        PCWrite = 0; Branch = 0; PCSrc = 2'b00;
        ALUSrcA = 1; RegWrite = 1; IorD = 0;
        MemWrite = 0; IRWrite = 0; RegDst = 1;
        MemtoReg = 0; ALUControl = 4'b0010; ALUSrcB = 2'b10; 
       end 

       branch : begin
        PCWrite = 0; Branch = 1; PCSrc = 2'b01;
        ALUSrcA = 1; RegWrite = 0; IorD = 0;
        MemWrite = 0; IRWrite = 0; RegDst = 0;
        MemtoReg = 0; ALUControl = 4'b0110; ALUSrcB = 2'b00; 
       end  

       AddiWriteback : begin
        PCWrite = 0; Branch = 0; PCSrc = 2'b00;
        ALUSrcA = 1; RegWrite = 1; IorD = 0;
        MemWrite = 0; IRWrite = 0; RegDst = 0;
        MemtoReg = 0; ALUControl = 4'b0010; ALUSrcB = 2'b10; 
       end 

       jump : begin
        PCWrite = 1; Branch = 0; PCSrc = 2'b10;
        ALUSrcA = 1; RegWrite = 0; IorD = 0;
        MemWrite = 0; IRWrite = 0; RegDst = 0;
        MemtoReg = 0; ALUControl = 4'b0010;  ALUSrcB = 2'b10; 
       end                                                                                                                                   
        default: begin
        PCWrite = 0; Branch = 0; PCSrc = 2'b00;
        ALUSrcA = 1; RegWrite = 0; IorD = 0;
        MemWrite = 0; IRWrite = 0; RegDst = 0;
        MemtoReg = 0; ALUControl = 4'b0010; ALUSrcB = 2'b10; 
       end
    endcase
end

endmodule