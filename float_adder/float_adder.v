module FAdd(
    input rst,
    input clk,
    input  [31:0]               a,
    input  [31:0]               b,
    output reg [31:0]           c,
    output reg [2:0]           state
);
    parameter NAN = 32'b01111111100000000000000000000001; // not a number
    parameter ZERO = 32'b0; // positive zero

    wire a_s = a[31];
    wire b_s = b[31];
    wire [7:0] a_e = a[30:23];
    wire [7:0] b_e = b[30:23];
    wire [22:0] a_m = a[22:0];
    wire [22:0] b_m = b[22:0];
    wire a_e_max = a_e == 8'b11111111;
    wire b_e_max = b_e == 8'b11111111;
    wire a_e_min = a_e == 8'b0;
    wire b_e_min = b_e == 8'b0;
    wire a_m_min = a_m == 23'b0;
    wire b_m_min = b_m == 23'b0;
    wire a_inf = a_e_max & a_m_min;
    wire b_inf = b_e_max & b_m_min;
    wire a_nan = a_e_max & ~a_m_min;
    wire b_nan = b_e_max & ~b_m_min;
    wire a_zero = a_e_min & a_m_min;
    wire b_zero = b_e_min & b_m_min;
    wire a_denorm = a_e_min & ~a_m_min;
    wire b_denorm = b_e_min & ~b_m_min;
    wire special_case = a_nan | b_nan | a_inf | b_inf | a_zero | b_zero;
    wire [31:0] special_output = (a_nan | b_nan) ? NAN :
    a_inf ? ((b_inf & (a_s ^ b_s)) ? NAN : a) :
    b_inf ? b :
    a_zero ? ((b_zero & (a_s ^ b_s) ? ZERO : b)) :
    b_zero ? a : 32'hffffffff;

    reg a_sign;
    reg b_sign;
    reg [26:0] a_add;
    reg [26:0] b_add;
    reg [7:0] a_exp;
    reg [7:0] b_exp;
    parameter READ = 3'd0,
    ALIGN = 3'd1,
    ADD = 3'd2,
    NORM = 3'd3,
    DENORM = 3'd4,
    ROUND = 3'd5,
    PACK = 3'd6,
    OUTPUT = 3'd7;
    reg c_sign;
    reg[27:0] c_add;
    reg[7:0] c_exp;

always @(posedge clk) begin
if (!rst) begin
    state <= READ;
end
else begin
case (state)
READ: begin
    a_sign <= a_s;
    b_sign <= b_s;
    a_add <= {~a_denorm, a_m, 3'b0};
    b_add <= {~b_denorm, b_m, 3'b0};
    a_exp <= a_denorm ? 8'b1 : a_e;
    b_exp <= b_denorm ? 8'b1 : b_e;
    c <= special_output;
    state <= special_case ? OUTPUT : ALIGN;
end
ALIGN: begin
    if (a_exp > b_exp) begin
        b_exp <= b_exp + 1;
        b_add <= b_add >> 1;
        b_add[0] <= b_add[0] | b_add[1]; // sticky bit to round
    end else if (a_exp < b_exp) begin
        a_exp <= a_exp + 1;
        a_add <= a_add >> 1;
        a_add[0] <= a_add[0] | a_add[1];
    end else begin
        state <= ADD;
    end
end
ADD: begin
    c_exp <= a_exp;
    if (a_sign == b_sign) begin
        c_add <= a_add + b_add;
        c_sign <= a_sign;
    end else if (a_add > b_add) begin
        c_add <= a_add - b_add;
        c_sign <= a_sign;
    end else begin
        c_add <= b_add - a_add;
        c_sign <= b_sign;
    end
    state <= NORM;
end
NORM: begin
    if (c_add[27]) begin // if the 28th bit is 1, shift right
        c_exp <= c_exp + 1;
        c_add <= c_add >> 1;
        c_add[0] <= c_add[0] | c_add[1];
    end else if (~c_add[26] & c_exp != 8'b0) begin // if the 27th bit is 0 and the exponent is not 0, shift left
        c_exp <= c_exp - 1;
        c_add <= c_add << 1;
    end else begin
        state <= DENORM;
    end
end
DENORM: begin
    if (c_exp == 8'b0) begin // if the exponent is 0, shift right
        c_exp <= c_exp + 1;
        c_add <= c_add >> 1;
        c_add[0] <= c_add[0] | c_add[1];
    end
    state <= ROUND;
end
ROUND: begin
    if (c_add[2] & (c_add[1] | c_add[0] | c_add[3])) begin
        c_add <= c_add + 4'b1000;
    end
    state <= PACK;
end
PACK: begin
    c[31] <= c_sign;
    c[22:0] <= c_add[25:3];
    if (c_add[27]) begin // overflow in rounding
        c[30:23] <= c_exp + 1;
    end else if (~c_add[26]) begin // denormalized number
        c[30:23] <= c_exp - 1;
    end else begin
        c[30:23] <= c_exp;
    end
    state <= OUTPUT;
end
OUTPUT: begin
end
endcase
end
end
endmodule