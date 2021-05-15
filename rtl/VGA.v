module VGA #(
	parameter
		W     = 640,
		H     = 480,
		Hbp   = 16,
		Hsync = 96,
		Hfp   = 48,
		Vbp   = 11,
		Vsync = 2,
		Vfp   = 31
) (
	input
		CLK,

	output
		HB, VB,
		HS_, VS_,

	output reg [$clog2(W)-1:0] X = 0,
	output reg [$clog2(H)-1:0] Y = 0
);
	wire
		xmax = X == W-1 + Hbp + Hsync + Hfp,
		ymax = Y == H-1 + Vbp + Vsync + Vfp;

	assign
		HB  = X >= W,
		VB  = Y >= H,
		HS_ = !(X >= W + Hbp && X < W + Hbp + Hsync),
		VS_ = !(Y >= H + Vbp && Y < H + Vbp + Vsync);

	/*
	 * Step through the full screen grid
	 */
	always @(posedge CLK)
		if (xmax) begin
			X <= 0;
			Y <= ymax ? 0 : Y+1;
		end else
			X <= X+1;
endmodule