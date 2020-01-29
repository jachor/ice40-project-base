project = display
device = up5k
package = uwg30
sources = display.v

include ../../../ice40.mk

sram: $(project).bin
	$(call announce, Writing to SRAM)
	iceprog -S $<

