MODNAME   = core.keycodes
LUAFILES  = init.lua
OBJCFILES = internal.m
HEADERS   =

CFLAGS  += -Wall -Wextra
LDFLAGS += -dynamiclib -undefined dynamic_lookup
LDFLAGS += -framework Cocoa
LDFLAGS += -framework Carbon

TGZFILE  = $(MODNAME).tgz
JSONFILE = $(MODNAME).json
OFILES  := $(OBJCFILES:m=o)
SOFILES := $(OBJCFILES:m=so)

all: $(JSONFILE)

$(SOFILES): $(OFILES) $(HEADERS)
	$(CC) $(OFILES) $(CFLAGS) $(LDFLAGS) -o $@

docs.json: $(OBJCFILES) $(LUAFILES)
	ruby gendocs.rb --json $^ > $@

docs.in.sql: docs.json
	ruby gendocs.rb --sqlin $^ > $@

docs.out.sql: docs.json
	ruby gendocs.rb --sqlout $^ > $@

docs.html.d: docs.json
	rm -rf $@
	mkdir -p $@
	ruby gendocs.rb --html $^ $@

$(TGZFILE): $(SOFILES) $(LUAFILES) docs.html.d docs.in.sql docs.out.sql
	tar -czf $@ $^

$(JSONFILE): $(TGZFILE) genmanifest.rb
	ruby genmanifest.rb $< > $@

clean:
	rm -rf $(OFILES) $(SOFILES) docs.json docs.in.sql docs.out.sql docs.html.d $(TGZFILE)

.PHONY: all clean
