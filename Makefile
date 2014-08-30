OBJCFILES = keycodes-internal.m
OFILES  := $(OBJCFILES:m=o)
SOFILES := $(OBJCFILES:m=so)

CFLAGS = -Wall -Wextra
LDFLAGS = -framework Cocoa -framework Carbon

all: $(SOFILES)

$(SOFILES): $(OFILES)
	echo compiling so file right now
	echo CFLAGS = $(CFLAGS)
	echo LDFLAGS = $(LDFLAGS)
	$(CC) $(OFILES) $(CFLAGS) $(LDFLAGS) -o $@

clean:
	rm -rf $(OFILES) $(SOFILES)

install:
	# cp $(SOFILES) $(LIBDIR)
	echo $(PREFIX)
	ls $(PREFIX)

.PHONY: all clean
