module bidirectional_io #(
	parameter WIDTH=16
)
(
	input output_enable,
	input [WIDTH-1:0] data,
	inout [WIDTH-1:0] bidir_variable,
	output [WIDTH-1:0] read_buffer
);
	
	// If we are using the bidir as an output, assign it an output value, 
	// otherwise assign it high-impedence
	assign bidir_variable = (output_enable ? data : {WIDTH{1'bz}});

	// Read in the current value of the bidir port, which comes either
	// from the input or from the previous assignment.
	assign read_buffer = bidir_variable;

endmodule