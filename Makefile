FAIL-SRC := $(shell find src/the.web-is.fail ! -type d | grep -v BITS)
FAIL-OBJS := $(patsubst src/%,build/%,$(FAIL-SRC))

all: stamps/sites

$(FAIL-OBJS): build/%.gmi: src/%.gmi src/the.web-is.fail/BITS/*.gmi
$(FAIL-OBJS): build/%: src/%
$(FAIL-OBJS):
	mkdir -p $(dir $@)
	name="$@"; \
	if test "$${name%.gmi}" != "$${name}"; then \
	    bin/eval-template -I src/the.web-is.fail/BITS < $< > $@.tmp; \
	    mv $@.tmp $@; \
	else \
	    cp $< $@; \
	fi

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
