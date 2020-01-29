project = blink
device = up5k
package = uwg30
sources = blink.v

include ../../../ice40.mk

sram: $(project).bin
	$(call announce, Writing to SRAM)
	iceprog -S $<

