`include "float_adder.v"

module test_float_adder;
	reg  [31:0] a, b, res;
	wire [31:0] answer;
	FAdd fadder (a, b, answer);
    initial begin
    	a = 1;
    	b = 2;
    	res = 10;
    	#1;
    	$display("%d + %d = %d", a, b, answer);
    	if (answer !== res) begin
    		$display("Wrong Answer! Expected: %d", res);
    		$fatal;
    	end
    	$display("Congratulations! You have passed all of the tests.");
    end
endmodule