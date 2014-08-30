OBJCFILES = keycodes-internal.m
OFILES  := $(OBJCFILES:m=o)
SOFILES := $(OBJCFILES:m=so)

CFLAGS += -Wall -Wextra -fobjc-arc
LDFLAGS += -framework Cocoa -framework Carbon -llua -dynamiclib -undefined dynamic_lookup

all: $(SOFILES)

$(SOFILES): $(OFILES)
	$(CC) $(OFILES) $(CFLAGS) $(LDFLAGS) -o $@

clean:
	rm -rf $(OFILES) $(SOFILES)

install:
	echo INSTALLING NOW
	cp keycodes.lua $(LUADIR)
	cp $(SOFILES) $(LIBDIR)
	echo PREFIX = $(PREFIX)
	echo LUADIR = $(LUADIR)
	echo LIBDIR = $(LIBDIR)
	echo DONE INSTALLING

.PHONY: all clean
