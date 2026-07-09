BUILD = build
FAIL-SRC := $(shell find src/the.web-is.fail ! -type d | grep -v BITS)
FAIL-OBJS := $(patsubst src/%,$(BUILD)/%,$(FAIL-SRC))
SHIZ-STATIC-SRC := $(shell find src/shizuka.space ! -type d | grep -v BITS | grep -v glog/)
SHIZ-GLOGSRC := $(shell find src/shizuka.space/glog ! -type d | grep -v BITS)
SHIZ-STATIC-OBJS := $(patsubst src/%,$(BUILD)/%,$(SHIZ-STATIC-SRC))
SHIZ-GLOGOBJ := $(foreach file,$(SHIZ-GLOGSRC),$(shell file=$(file); file=build/$${file#src/}; file=$${file%.gmi}/index.gmi; echo $$file))
SHIZ-GLOGDEX := $(BUILD)/shizuka.space/glog/index.gmi

all: stamps/sites

$(filter %.gmi,$(FAIL-OBJS)): $(BUILD)/%.gmi: src/%.gmi src/the.web-is.fail/BITS/*.gmi Makefile bin/eval-template
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

stamps/shizuka.space: stamps/shizuka.space-static stamps/shizuka.space-glog
	touch $@

stamps/shizuka.space-static: $(SHIZ-STATIC-OBJS)
	touch $@

$(SHIZ-STATIC-OBJS): $(BUILD)/%.gmi: src/%.gmi src/shizuka.space/BITS/*.gmi Makefile bin/eval-template
	mkdir -p $(dir $@)
	bin/eval-template -I src/shizuka.space/BITS < $< > $@.tmp
	mv $@.tmp $@

stamps/shizuka.space-glog: $(SHIZ-GLOGDEX)
	touch $@

$(SHIZ-GLOGDEX): $(SHIZ-GLOGOBJ) Makefile bin/eval-template
	for article in $(SHIZ-GLOGOBJ); do \
	    date=$${article%/index.gmi}; \
	    date=$${date##*/}; \
	    heading=$$(sed -ne '/^#/ { s/^#* //p; q; }' < $$article); \
	    printf '=> %s/ %s - %s\n' "$$date" "$$date" "$$heading"; \
	done >| $@.tmp
	mv $@.tmp $@

$(SHIZ-GLOGOBJ): $(BUILD)/shizuka.space/glog/%/index.gmi: src/shizuka.space/glog/%.gmi
	mkdir -p $(dir $@)
	bin/eval-template -I src/shizuka.space/BITS < $< > $@.tmp
	mv $@.tmp $@

.PHONY: clean

clean:
	rm -fr $(BUILD)/*/* stamps
# ^ Leave $(BUILD/$(SITENAME) around, in case build/ is symlinked to
# /var/gemini, etc
