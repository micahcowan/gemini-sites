BUILD = /var/gemini/
FAIL-SRC := $(shell find src/the.web-is.fail ! -type d | grep -v BITS)
FAIL-OBJS := $(patsubst src/%,$(BUILD)/%,$(FAIL-SRC))

all: stamps/sites

$(filter %.gmi,$(FAIL-OBJS)): $(BUILD)/%.gmi: src/%.gmi src/the.web-is.fail/BITS/*.gmi
	mkdir -p $(dir $@)
	bin/eval-template -I src/the.web-is.fail/BITS < $< > $@.tmp
	mv $@.tmp $@

$(filter-out %.gmi,$(FAIL-OBJS)): $(BUILD)/%: src/%
	mkdir -p $(dir $@)
	cp $< $@

foo:
	mkdir -p $(dir $@)
	cp $< $@

stamps/sites: stamps stamps/the.web-is.fail stamps/shizuka.space
	touch $@

stamps:
	mkdir -p stamps

stamps/the.web-is.fail: $(FAIL-OBJS)
	touch $@

stamps/shizuka.space:
	mkdir -p $(BUILD)/shizuka.space
	echo "Hello, quiet world!" >| $(BUILD)/shizuka.space/index.gmi
	touch $@

.PHONY: clean

clean:
	rm -fr $(BUILD)/*/*
