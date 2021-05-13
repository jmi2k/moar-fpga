BOARD   = icesugar_pro
PACKAGE = CABGA256
FCLK    = 25000000
TOP     = SoC
TEST    = SoC
TTY     = /dev/ttyACM0
BAUDS   = 9600

all: $(TOP).bit

diagram: rtl/$(TEST).v
	yosys -q \
		-D'FCLK=${FCLK}' \
		-p "read -incdir rtl; show -colors `date +%H%M%S`" \
		$<

wave: test/$(TEST).vcd
	gtkwave $<

dfu: $(TOP).bit
	dfu-util -D $<

serial:
	picocom -q -b ${BAUDS} ${TTY}

test/%: test/%.v
	iverilog -Wall -Irtl \
		-D'DUMP="$@.vcd"' \
		-D'FCLK=${FCLK}' \
		-o $@ \
		$<

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
	yosys -q \
		-D'FCLK=${FCLK}' \
		-p 'read -incdir rtl; synth_ecp5 -json $@' \
		$<

%.config: %.json
	nextpnr-ecp5 \
		--json $< \
		--textcfg $@ \
		--25k \
		--package ${PACKAGE} \
		--lpf ${BOARD}.lpf

%.bit: rtl/%.config
	ecppack \
		--input $< \
		--bit $@

clean:
	rm -f \
		EVA.hex \
		*.bit \
		*.config \
		*.json \
		test/*.vcd

.PHONY: all diagram wave dfu clean
