BOARD = orangecrab_r0.2
TOP   = SoC
TEST  = SoC

all: $(TOP).bit

test: $(TEST).vcd
	gtkwave $<

dfu: $(TOP).bit
	dfu-util -D $<

test/%: test/%.v
	iverilog -Wall -Irtl -o $@ $<

%.vcd: test/%
	vvp $<

%.hex: %.png
	./png2hex.py $< \
		| od -v -A x -t x1 \
		| sed 's|^|@|' > $@

%.hex: %.txt
	(cat $< | sed 's|$$|\r|'; printf "\0") \
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
		$(TEST).vcd

.PHONY: all test dfu clean
