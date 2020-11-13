module TX #(
	parameter
		Bauds = 'bx,
		Wdata = 'bx,
		Wstop = 'bx,
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
		Nticks = Fclk/Bauds;

	reg [$clog2(Nticks)-1:0] ticks = Nticks;
	reg [$clog2(Wframe)-1:0] index = Wframe;
	reg [Wdata-1:0]          data  = 'bx;

	assign
		RDY = !RST && !OE;

	/*
	 * Generate timing
	 */
	always @(posedge CLK)
		if (index < Wframe)
			case (1)
				RST:     ticks <= Nticks;
				!ticks:  ticks <= Nticks;
				default: ticks <= ticks-1;
			endcase

	/*
	 * Update bit position
	 */
	always @(posedge CLK)
		case(1)
			RST:    index <= Wframe;
			OE:     index <= 0;
			!ticks: index <= index+1;
		endcase

	/*
	 * Fetch data from DIN, send frames to TXD
	 */
	always @(posedge CLK)
		case (1)
			RST:             TXD <= 1;
			OE:              data <= DIN;
			index == 0:      TXD <= 0;
			index < 1+Wdata: TXD <= data[index-1];
			index < Wframe:  TXD <= 1;
			default:         TXD <= 1;
		endcase
endmodule
