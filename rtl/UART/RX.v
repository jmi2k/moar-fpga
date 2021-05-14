module RX #(
	parameter
		Bauds = 'bx,
		Wdata = 'bx,
		Wstop = 'bx
) (
	output reg [Wdata-1:0] DOUT = 'bx,
	output reg             INT  = 0,

	input
		CLK,
		RXD
);
	localparam
		/*       Start + Data  + Stop */
		Wframe = 1     + Wdata + Wstop,
		Nticks = `FCLK/Bauds;

	reg [$clog2(Nticks)-1:0] ticks = Nticks/2;
	reg [$clog2(Wframe)-1:0] index = Wframe;

	/*
	 * Generate timing
	 */
	always @(posedge CLK)
		if (index < Wframe)
			case (1)
				!ticks:  ticks <= index < Wframe-1 ? Nticks : Nticks/2;
				default: ticks <= ticks-1;
			endcase

	/*
	 * Update bit position
	 */
	always @(posedge CLK)
		if (!RXD & index == Wframe)
			index <= 0;
		else if (!ticks)
			case (1)
				index == 0:      index <= !RXD ? index+1 : Wframe;
				index < 1+Wdata: index <= index+1;
				index < Wframe:  index <=  RXD ? index+1 : Wframe;
			endcase

	/*
	 * Fetch bits from RXD, build data on DOUT, raise INT when done
	 */
	always @(posedge CLK)
		if (INT)
			INT <= 0;
		else if (!ticks)
			case (1)
				index == 0:        INT <= 0;
				index < 1+Wdata:   DOUT[index-1] <= RXD;
				index >= Wframe-1: INT <= 1;
			endcase
endmodule
