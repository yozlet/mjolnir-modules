OBJCFILES = keycodes-internal.m
OFILES  := $(OBJCFILES:m=o)
SOFILES := $(OBJCFILES:m=so)

all: $(SOFILES)

$(SOFILES): $(OFILES)
	$(CC) $(OFILES) $(CFLAGS) $(LDFLAGS) -o $@

clean:
	rm -rf $(OFILES) $(SOFILES)

install:
	@echo $(PREFIX)

.PHONY: all clean
