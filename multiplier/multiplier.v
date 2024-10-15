module FALayer(
    input  [31:0]               a,
    input  [31:0]               b,
    input  [31:0]              c,
    output  [31:0]              result,
    output  [31:0]              carry
);
    assign result = a ^ b ^ c;
    assign carry = (a & b) | (c & (a ^ b));
endmodule

module Multi(
    input  [31:0]               a,
    input  [31:0]               b,
    output  [31:0]          prod
);
    assign prod[0] = a[0] & b[0];
    wire [31:0] result [0:29];
    wire [31:0] carry [0:29];
    genvar i;
    generate
        for (i = 0; i < 30; i = i + 1) begin: FALayerLoop
            if (i == 0) begin
                FALayer fa0(
                        .a(b[0] ? {1'b0, a[31:1]} : 32'b0),
                        .b(b[1] ? a : 32'b0),
                        .c(b[2] ? {a[30:0], 1'b0} : 32'b0),
                        .result(result[0]),
                        .carry(carry[0])
                    );
            end else begin
                FALayer fa(
                        .a({b[i + 1] ? a[31] : 1'b0, result[i - 1][31:1]}),
                        .b(carry[i - 1]),
                        .c(b[i + 2] ? {a[30:0], 1'b0} : 32'b0),
                        .result(result[i]),
                        .carry(carry[i])
                    );
            end
            assign prod[i + 1] = result[i][0];
        end
    endgenerate
    assign prod[31] = result[29][1] ^ carry[29][0];
endmodule