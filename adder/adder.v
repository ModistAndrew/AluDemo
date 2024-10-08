module Add4(
    input  [3:0]               a,
    input  [3:0]               b,
    output  [3:0]              sum,
    input                      cin,
    output                     cout
);
    wire [3:0] p = a ^ b;
    wire [3:0] g = a & b;
    wire [3:0] c;
    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
    assign cout = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c[0]);
    assign sum = p ^ c;
endmodule

module Add16(
    input  [15:0]               a,
    input  [15:0]               b,
    output  [15:0]              sum,
    input                       cin,
    output                      cout
);
    wire [3:0] c;
    assign c[0] = cin;
    Add4 add4_0(
        .a(a[3:0]),
        .b(b[3:0]),
        .sum(sum[3:0]),
        .cin(c[0]),
        .cout(c[1])
    );
    Add4 add4_1(
        .a(a[7:4]),
        .b(b[7:4]),
        .sum(sum[7:4]),
        .cin(c[1]),
        .cout(c[2])
    );
    Add4 add4_2(
        .a(a[11:8]),
        .b(b[11:8]),
        .sum(sum[11:8]),
        .cin(c[2]),
        .cout(c[3])
    );
    Add4 add4_3(
        .a(a[15:12]),
        .b(b[15:12]),
        .sum(sum[15:12]),
        .cin(c[3]),
        .cout(cout)
    );
endmodule

module Add(
    input  [31:0]               a,
    input  [31:0]               b,
    output  [31:0]              sum
);
    wire c;
    wire [15:0] sum0, sum1;
    Add16 add16_0(
        .a(a[15:0]),
        .b(b[15:0]),
        .sum(sum[15:0]),
        .cin(1'b0),
        .cout(c)
    );
    Add16 add16_10(
        .a(a[31:16]),
        .b(b[31:16]),
        .sum(sum0),
        .cin(1'b0)
    );
    Add16 add16_11(
        .a(a[31:16]),
        .b(b[31:16]),
        .sum(sum1),
        .cin(1'b1)
    );
    assign sum[31:16] = c ? sum1 : sum0;
endmodule