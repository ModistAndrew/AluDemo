`include "multiplier.v"

module test_multiplier;
	reg  [31:0] a, b;
	wire [31:0] answer;
	Multi multiplier (a, b, answer);
	wire [31:0] res = a * b;
	integer i;
	initial begin
		for(i=1; i<=100; i=i+1) begin
			a[31:0] = $random;
			b[31:0] = $random;
			#1;
			$display("TESTCASE %d: %d * %d = %d", i, a, b, answer);
			if (answer !== res) begin
				$display("Wrong Answer! Expected: %d", res);
				$fatal;
			end
		end
		$display("Congratulations! You have passed all of the tests.");
	end
endmodule