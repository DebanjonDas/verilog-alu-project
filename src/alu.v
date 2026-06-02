module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
assign sum  = a ^ b ^ cin;
assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

//ADDITION OF A AND B
module adder #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input cin,
    output [WIDTH-1:0] sum,
    output cout
);   
wire [WIDTH-1:0] c;
genvar i;
full_adder FA0(a[0], b[0], cin, sum[0], c[0]);
generate
    for(i = 1; i < WIDTH; i = i + 1) begin
        full_adder FA(a[i], b[i], c[i-1], sum[i], c[i]);
    end
endgenerate
assign cout = c[WIDTH-1];
endmodule

//SUBTRACTION OF A AND B USING 2'S COMPLEMENT
module subtractor #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] diff,
    output borrow
);
wire cout;
adder #(WIDTH) SUB(
    .a(a),
    .b(~b),
    .cin(1'b1),
    .sum(diff),
    .cout(cout)
);
assign borrow=~cout;
endmodule

//AND OPERATION
module and_op #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a, b,
    output [WIDTH-1:0] y
);
assign y = a & b;
endmodule

//OR OPERATION
module or_op #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a, b,
    output [WIDTH-1:0] y
);
assign y = a | b;
endmodule

//XOR OPERATION
module xor_op #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a, b,
    output [WIDTH-1:0] y
);
assign y = a ^ b;
endmodule

//NOT OPERATION
module not_op #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a,
    output [WIDTH-1:0] y
);
assign y = ~a;
endmodule

//LEFT SHIFT
module lshift #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a,
    output [WIDTH-1:0] y,
    output carry //SHIFTED OUT MSB OR LOST BIT
);
assign y = a << 1;
assign carry=a[WIDTH-1];
endmodule

//RIGHT SHIFT
module rshift #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a,
    output [WIDTH-1:0] y,
    output carry //SHIFTED OUT LSB OR LOST BIT
);
assign y = a >> 1;
assign carry=a[0];
endmodule

//ARITHMETIC RIGHT SHIFT
module arshift #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a,
    output [WIDTH-1:0] y,
    output carry
);
assign y = $signed(a) >>> 1;
assign carry = a[0];
endmodule

//INCREMENT
module increment #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a,
    output [WIDTH-1:0] y,
    output cout
);
adder #(WIDTH) INC(
    .a(a),
    .b({{(WIDTH-1){1'b0}}, 1'b1}),
    .cin(1'b0),
    .sum(y),
    .cout(cout)
);
endmodule

//DECREMENT
module decrement #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a,
    output [WIDTH-1:0] y,
    output borrow
);
wire cout;
adder #(WIDTH) DEC(
    .a(a),
    .b({WIDTH{1'b1}}), // -2
    .cin(1'b0),      // +1
    .sum(y),
    .cout(cout)
);
assign borrow = ~cout;
endmodule

//COMPARE EQUAL
module equal #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a, b,
    output eq
);
assign eq = (a == b);
endmodule

//COMPARE GREATER
module greater #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a, b,
    output gt
);
assign gt = (a > b);
endmodule

//COMPARE LESS
module less #(parameter WIDTH = 8)(
    input [WIDTH-1:0] a, b,
    output lt
);
assign lt = (a < b);
endmodule

//FINAL ALU MODEL
module alu #(parameter WIDTH = 8)(
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input [3:0] opcode,
    output reg [WIDTH-1:0] result,
    output reg C,//CARRY FLAG
    output reg Z,//ZERO FLAG
    output reg V,//OVERFLOW FLAG
    output reg N//NEGATIVE OR SIGN FLAG
);
wire [WIDTH-1:0] add_out;
wire [WIDTH-1:0] sub_out;
wire [WIDTH-1:0] inc_out;
wire [WIDTH-1:0] dec_out;
wire add_cout;
wire sub_borrow;
wire inc_cout;
wire dec_borrow;
wire [WIDTH-1:0] and_out;
wire [WIDTH-1:0] or_out;
wire [WIDTH-1:0] xor_out;
wire [WIDTH-1:0] not_out;
wire [WIDTH-1:0] lshift_out;
wire lshift_carry;
wire [WIDTH-1:0] rshift_out;
wire rshift_carry;
wire [WIDTH-1:0] arshift_out;
wire arshift_carry;
wire eq;
wire gt;
wire lt;
adder #(WIDTH) ADD(
    .a(A),
    .b(B),
    .cin(1'b0),
    .sum(add_out),
    .cout(add_cout)
);
subtractor #(WIDTH) SUB(
    .a(A),
    .b(B),
    .diff(sub_out),
    .borrow(sub_borrow)
);
and_op #(WIDTH) AND1(
    .a(A),
    .b(B),
    .y(and_out)
);
or_op #(WIDTH) OR1(
    .a(A),
    .b(B),
    .y(or_out)
);
xor_op #(WIDTH) XOR1(
    .a(A),
    .b(B),
    .y(xor_out)
);
not_op #(WIDTH) NOT1(
    .a(A),
    .y(not_out)
);
lshift #(WIDTH) LS1(
    .a(A),
    .y(lshift_out),
    .carry(lshift_carry)
);
rshift #(WIDTH) RS1(
    .a(A),
    .y(rshift_out),
    .carry(rshift_carry)
);
arshift #(WIDTH) ARS1(
    .a(A),
    .y(arshift_out),
    .carry(arshift_carry)
);
increment #(WIDTH) INC(
    .a(A),
    .y(inc_out),
    .cout(inc_cout)
);
decrement #(WIDTH) DEC(
    .a(A),
    .y(dec_out),
    .borrow(dec_borrow)
);
equal #(WIDTH) EQ(
    .a(A),
    .b(B),
    .eq(eq)
);
greater #(WIDTH) GT(
    .a(A),
    .b(B),
    .gt(gt)
);
less #(WIDTH) LT(
    .a(A),
    .b(B),
    .lt(lt)
);
always @(*) begin
result = {WIDTH{1'b0}};
    C = 1'b0;
    Z = 1'b0;
    V = 1'b0;
    N = 1'b0;
case(opcode)
4'b0000: begin
            result = add_out;
            C = add_cout;
            V = (~(A[WIDTH-1] ^ B[WIDTH-1])) & (A[WIDTH-1] ^ add_out[WIDTH-1]);
           end
4'b0001: begin
            result = sub_out;
            C = ~sub_borrow;
            V = (A[WIDTH-1] ^ B[WIDTH-1]) & (A[WIDTH-1] ^ sub_out[WIDTH-1]);
         end
4'b0010: result = and_out;
4'b0011: result = or_out;
4'b0100: result = xor_out;
4'b0101: result = not_out;
4'b0110: begin
             result = lshift_out;
             C = lshift_carry;
         end
4'b0111: begin
             result = rshift_out;
             C = rshift_carry;
         end
4'b1000: begin
            result = arshift_out;
            C = arshift_carry;
         end
4'b1001: begin
            result = inc_out;
            C = inc_cout;
            V = (~A[WIDTH-1]) & inc_out[WIDTH-1];
         end
4'b1010: begin
            result = dec_out;
            C = ~dec_borrow;
            V = A[WIDTH-1] & (~dec_out[WIDTH-1]);
         end
4'b1011: result = {{(WIDTH-1){1'b0}}, eq};
4'b1100: result = {{(WIDTH-1){1'b0}}, gt};
4'b1101: result = {{(WIDTH-1){1'b0}}, lt};
default: result = {WIDTH{1'b0}};
endcase
Z = (result == {WIDTH{1'b0}});
N = result[WIDTH-1];
end
endmodule

