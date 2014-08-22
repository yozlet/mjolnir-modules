MODNAME   = core.keycodes
LUAFILES  = init.lua
OBJCFILES = internal.m
HEADERS   =

CFLAGS  += -Wall -Wextra
LDFLAGS += -dynamiclib -undefined dynamic_lookup
LDFLAGS += -framework Cocoa
LDFLAGS += -framework Carbon

TGZFILE  = $(MODNAME).tgz
MDFILE   = metadata.json
DOCSFILE = docs.json
OFILES  := $(OBJCFILES:m=o)
SOFILES := $(OBJCFILES:m=so)

all: $(MDFILE)

$(SOFILES): $(OFILES) $(HEADERS)
	$(CC) $(OFILES) $(CFLAGS) $(LDFLAGS) -o $@

$(DOCSFILE): $(OBJCFILES) $(LUAFILES) gendocs.rb
	ruby gendocs.rb $(OBJCFILES) $(LUAFILES) > $@

$(TGZFILE): $(SOFILES) $(LUAFILES) $(DOCSFILE)
	tar -czf $@ $^

$(MDFILE): $(TGZFILE) genmetadata.rb
	ruby genmetadata.rb $(TGZFILE) > $@

clean:
	rm -rf $(OFILES) $(SOFILES) $(DOCSFILE) $(TGZFILE)

.PHONY: all clean
