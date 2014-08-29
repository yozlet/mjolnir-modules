MODNAME   = core.keycodes
OBJCFILES = keycodes-internal.m

CFLAGS  += -Wall -Wextra
CFLAGS  += -fobjc-arc
LDFLAGS += -dynamiclib -undefined dynamic_lookup
LDFLAGS += -framework Cocoa
LDFLAGS += -framework Carbon

OFILES  := $(OBJCFILES:m=o)
SOFILES := $(OBJCFILES:m=so)

all: $(SOFILES)

$(SOFILES): $(OFILES)
	$(CC) $(OFILES) $(CFLAGS) $(LDFLAGS) -o $@

clean:
	rm -rf $(OFILES) $(SOFILES)

.PHONY: all clean
