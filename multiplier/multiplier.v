module Multi(
    input  [31:0]               a,
    input  [31:0]               b,
    output  [31:0]          prod
);
    assign prod = a * b;
endmodule