OBJCFILES = keycodes-internal.m
OFILES  := $(OBJCFILES:m=o)
SOFILES := $(OBJCFILES:m=so)

CFLAGS += -fobjc-arc -Wall -Wextra
LDFLAGS += -framework Cocoa -framework Carbon -llua

all: $(SOFILES)

$(SOFILES): $(OFILES)
	$(CC) $(OFILES) $(CFLAGS) $(LDFLAGS) -o $@

clean:
	rm -rf $(OFILES) $(SOFILES)

.PHONY: all clean
