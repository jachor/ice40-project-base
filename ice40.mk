# Makefile included from projects using iCE40 FPGAs.
#
# How to use?
#   Create Makefile for your project, set required variables,
#   add "include <this_makefile>".
#
# Variables:
#   project - Project name, used as base for generated files.
#   device - Device name, for example 5k, 8k, up5k.
#   package - Device package, for example ct256.
#   sources - Source Verilog files. One of them should define 'top' component.
#   physical_constraints_file - File mapping signals to pins. Default: "$(project).pcf".
#
# Required files:
#   $(physical_constraints_file) - Mapping signals to pins.
#
# Outputs:
#   $(project).bin - Bitstream for FPGA.
#   $(project).rpt - Timing report.

physical_constraints_file ?= $(project).pcf

ifndef project
$(error project name not set)
endif

ifndef device
$(error device name not set)
endif

ifndef package
$(error device package not set)
endif

ifndef sources
$(error sources not set)
endif

define announce
	@tput setaf 2
	@echo "> $1"
	@tput sgr0
endef

.PHONY: all clean

all: $(project).bin $(project).rpt

clean:
	rm -f \
		$(project).blif \
		$(project).asc \
		$(project).bin \
		$(project).rpt

$(project).blif: $(sources)
	$(call announce, Technology mapping)
	yosys -p 'synth_ice40 -top top -blif $@' $<

$(project).asc: $(physical_constraints_file) $(project).blif
	$(call announce, Placing and routing)
# arachne-pnr takes device without 'hx', 'lp', 'up' prefix.
	arachne-pnr \
		-d $(subst hx,,$(subst lp,,$(subst up,,$(device)))) \
		-P $(package) -o $@ -p $^

$(project).bin: $(project).asc
	$(call announce, Packing bitstream)
	icepack $< $@

$(project).rpt: $(project).asc
	$(call announce, Writing timing report)
	icetime -d $(device) -mtr $@ $<

