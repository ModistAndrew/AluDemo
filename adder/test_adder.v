/* ACM Class System (I) Fall Assignment 1
 *
 *
 * This file is used to test your adder.
 * Please DO NOT modify this file.
 *
 * GUIDE:
 *   1. Create a RTL project in Vivado
 *   2. Put `adder.v' OR `adder2.v' into `Sources', DO NOT add both of them at the same time.
 *   3. Put this file into `Simulation Sources'
 *   4. Run Behavioral Simulation
 *   5. Make sure to run at least 100 steps during the simulation (usually 100ns)
 *   6. You can see the results in `Tcl console'
 *
 */

`include "adder.v"

module test_adder;
	reg  [31:0] a, b;
	wire [31:0] answer;
	Add adder (a, b, answer);
	wire [31:0] res = a + b;
	integer i;
	initial begin
		for(i=1; i<=100; i=i+1) begin
			a[31:0] = $random;
			b[31:0] = $random;
			#1;
			$display("TESTCASE %d: %d + %d = %d", i, a, b, answer);
			if (answer !== res) begin
				$display("Wrong Answer! Expected: %d", res);
				$fatal;
			end
		end
		$display("Congratulations! You have passed all of the tests.");
	end
endmodule