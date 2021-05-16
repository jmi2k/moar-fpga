`include "BRAM1.v"
`include "Delay.v"
`include "UART.v"
`include "VGA.v"

module SoC #(
	parameter
		Bauds = 9_600,
		W     = 640,
		H     = 480
) (
	input
		CLK,
		RXD,

	output
		HS_, VS_,
		R, G, B,
		TXD
);
	reg [7:0] text [0:1_024];
	reg       vram [0:W*H];

	reg [18:0] taddr = 0;
	reg  [7:0] rtou  = 0;
	reg        pixel = 'bx;

	wire [$bits(W*H)-1:0] vaddr;
	wire   [$bits(W)-1:0] x;
	wire   [$bits(H)-1:0] y;

	wire [7:0]
		tout;

	wire
		hbraw, vbraw,
		hsraw_, vsraw_,
		hb, vb,
		uhasc,
		urdy,
		ven,
		vout;

	assign
		ven   = !hb & !vb,
		R     = ven & pixel,
		G     = ven & pixel,
		B     = ven & pixel,
		vaddr = W*y + x;

	UART #(
		.Bauds(Bauds)
	) uart(
		.CLK(CLK),
		.DIN(rtou),
		.OE(urdy),
		.RDY(urdy),
		.TXD(TXD),
		.RXD(RXD),
		.INT(uhasc)
	);

	VGA vga(
		.CLK(CLK),
		.HB(hbraw),
		.VB(vbraw),
		.HS_(hsraw_),
		.VS_(vsraw_),
		.X(x),
		.Y(y)
	);

	Delay #(
		.Wdata(4)
	) delay(
		.CLK(CLK),
		.IN( {hbraw, vbraw, hsraw_, vsraw_}),
		.OUT({hb,    vb,    HS_,    VS_})
	);

	initial begin
		$readmemh("hello.hex", text);
		$readmemh("EVA.hex", vram);
	end

	/*
	 * Step through the stored string
	 */
	always @(posedge CLK)
		if (|rtou)
			taddr <= taddr+urdy;

	/*
	 * Retrieve data from ROM
	 */
	always @(posedge CLK) begin
		pixel <= vram[vaddr];
		rtou  <= text[taddr];
	end

endmodule
