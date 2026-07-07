FAIL-SRC := $(shell find src/the.web-is.fail ! -type d | grep -v BITS)
FAIL-OBJS := $(patsubst src/%,build/%,$(FAIL-SRC))

all: stamps/sites

$(filter %.gmi,$(FAIL-OBJS)): build/%.gmi: src/%.gmi src/the.web-is.fail/BITS/*.gmi
	mkdir -p $(dir $@)
	bin/eval-template -I src/the.web-is.fail/BITS < $< > $@.tmp
	mv $@.tmp $@

$(filter-out %.gmi,$(FAIL-OBJS)): build/%: src/%
	mkdir -p $(dir $@)
	cp $< $@

foo:
	mkdir -p $(dir $@)
	cp $< $@

stamps/sites: stamps stamps/the.web-is.fail
	touch $@

stamps:
	mkdir -p stamps

stamps/the.web-is.fail: $(FAIL-OBJS)
	touch $@

.PHONY: clean

clean:
	rm -fr build
