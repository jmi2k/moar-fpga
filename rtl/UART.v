module UART #(
	parameter
		Bauds = 115_200,
		Wdata = 8,
		Wstop = 1,
		Fclk  = 'bx
) (
	output reg TXD = 1,

	input [Wdata-1:0] DIN,

	input
		CLK,
		RST,
		OE,

	output
		RDY
);
	localparam
		/*       Start + Data  + Stop */
		Wframe = 1     + Wdata + Wstop,
		Ntick  = Fclk/Bauds;

	reg  [$clog2(Ntick)-1:0]  tick  = Ntick;
	reg  [$clog2(Wframe)-1:0] index = Wframe;
	reg  [Wdata-1:0]          data  = 'bx;
	wire [Wframe-1:0]         frame = {{Wstop{1'b1}}, data, 1'b0};

	assign
		RDY = !OE && index == Wframe;

	always @(posedge CLK)
		tick <= tick == 0 ? Ntick : tick-1;

	always @(posedge CLK)
		if (index < Wframe) begin
			TXD <= frame[index];
			if (tick == 0)
				index <= index+1;
		end else if (OE) begin
			data <= DIN;
			index <= 0;
			TXD <= frame[0];
		end else
			TXD <= 1;
endmodule
