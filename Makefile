BOARD = orangecrab_r0.2
TOP   = SoC
TEST  = SoC

all: $(TOP).bit

diagram: rtl/$(TEST).v
	yosys -q -p "read -incdir rtl; show -colors `date +%H%M%S`" $<

wave: test/$(TEST).vcd
	gtkwave $<

dfu: $(TOP).bit
	dfu-util -D $<

test/%: test/%.v
	iverilog -D'DUMP="$@.vcd"' -Wall -Irtl -o $@ $<

%.vcd: %
	vvp $<

%.hex: %.png
	./png2hex.py $< \
		| od -v -A x -t x1 \
		| sed 's|^|@|' > $@

%.hex: %.txt
	(printf "\0" | cat $< -) \
		| od -v -A x -t x1 \
		| sed 's|^|@|' > $@

%.json: %.v
	yosys -q -p 'read -incdir rtl; synth_ecp5 -json $@' $<

%.config: %.json
	nextpnr-ecp5 \
		--json $< \
		--textcfg $@ \
		--25k \
		--package CSFBGA285 \
		--lpf ${BOARD}.pcf

%.bit: rtl/%.config
	ecppack \
		--compress \
		--freq 38.8 \
		--input $< \
		--bit $@

clean:
	rm -f \
		EVA.hex \
		$(TOP).bit \
		$(TOP).config \
		$(TOP).json \
		test/$(TEST).vcd

.PHONY: all diagram wave dfu clean
