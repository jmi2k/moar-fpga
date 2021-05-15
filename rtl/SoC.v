`include "BRAM1.v"
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
	reg [7:0] text [1_024:0];
	reg       vram   [W*H:0];

	reg [18:0] taddr = 0;
	reg  [7:0] rtou  = 'hff;

	wire [$bits(W*H)-1:0] vaddr;
	wire   [$bits(W)-1:0] x;
	wire   [$bits(H)-1:0] y;

	wire [7:0]
		tout,
		uout;

	wire
		hb, vb,
		uhasc,
		urdy,
		ven,
		vout;

	assign
		ven   = !hb & !vb,
		R     = ven & vout,
		G     = ven & vout,
		B     = ven & vout,
		tout  = text[taddr],
		vaddr = W*y + x,
		vout  = vram[vaddr];

	UART #(
		.Bauds(Bauds)
	) uart(
		.CLK(CLK),
		.DIN(rtou),
		.DOUT(uout),
		.OE(urdy),
		.RDY(urdy),
		.TXD(TXD),
		.RXD(RXD),
		.INT(uhasc)
	);

	VGA vga(
		.CLK(CLK),
		.HB(hb),
		.VB(vb),
		.HS_(HS_),
		.VS_(VS_),
		.X(x),
		.Y(y)
	);

	initial begin
		$readmemh("hello.hex", text);
		$readmemh("EVA.hex", vram);
	end

	/*
	 * Step through the stored string
	 */
	always @(posedge CLK) begin
		if (urdy)  rtou = tout;
		if (|rtou) taddr <= taddr+urdy;
	end
endmodule
