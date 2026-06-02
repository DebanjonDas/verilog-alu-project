//TESTBENCH
module tb();
parameter WIDTH=8;
reg [WIDTH-1:0] A,B;
reg [3:0] opcode;
wire [WIDTH-1:0] result;
wire C,Z,V,N;
alu #(WIDTH) a1(A,B,opcode,result,C,Z,V,N);
task run_op;
    input [3:0] op;
    begin
        opcode = op;
        #5;
        $display("time=%0t A=%d(%b) B=%d(%b) opcode=%b result=%d(%b) Carryflag=%b zeroflag=%b overflowflag=%b negativeflag=%b",$time,A,A,B,B,opcode,result,result,C,Z,V,N);
    end
endtask

task test_all_opcodes;
begin
    run_op(4'b0000); // ADD
    run_op(4'b0001); // SUB
    run_op(4'b0010); // AND
    run_op(4'b0011); // OR
    run_op(4'b0100); // XOR
    run_op(4'b0101); // NOT
    run_op(4'b0110); // LSHIFT
    run_op(4'b0111); // RSHIFT
    run_op(4'b1000); // ARSHIFT
    run_op(4'b1001); // INC
    run_op(4'b1010); // DEC
    run_op(4'b1011); // EQ
    run_op(4'b1100); // GT
    run_op(4'b1101); // LT
end
endtask
initial begin 
    $dumpfile("alu8.vcd");
    $dumpvars(0,tb);

$display("\n==== TEST SET 1 ====");
 A = 8'd16;  B = 8'd10;
    test_all_opcodes();

$display("\n==== TEST SET 2 ====");
    A = 8'd127; B = 8'd1;
    test_all_opcodes();

$display("\n==== TEST SET 3 ====");
    A = 8'd5;   B = 8'd10;
    test_all_opcodes();

    $finish;
end 
endmodule