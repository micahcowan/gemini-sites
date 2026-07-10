BUILD = build
FAIL-SRC := $(shell find src/the.web-is.fail ! -type d | grep -v BITS)
FAIL-OBJS := $(patsubst src/%,$(BUILD)/%,$(FAIL-SRC))
SHIZ-STATIC-SRC := $(shell find src/shizuka.space ! -type d | grep -v BITS | grep -v glog/)
SHIZ-STATIC-OBJS := $(patsubst src/%,$(BUILD)/%,$(SHIZ-STATIC-SRC))
SHIZ-GLOGSRC := $(shell find src/shizuka.space/glog ! -type d | grep -v BITS)
SHIZ-GLOGOBJ := $(foreach obj,$(SHIZ-GLOGSRC),$(shell obj=$(obj); obj=build/$${obj#src/}; date=$${obj##*/}; date=$${date%.gmi}; date=$$(echo "$$date" | tr - /); echo "$(BUILD)/shizuka.space/glog/$${date}/index.gmi"))
SHIZ-GLOGDEX := $(BUILD)/shizuka.space/glog/index.gmi

define make-shiz-glog-rule
$(1): $(call make-shiz-glog-src,$(1)) Makefile bin/eval-template
endef
make-shiz-glog-src = $(shell date=$1; date=$${date#$(BUILD)/shizuka.space/glog/}; date=$${date%/index.gmi}; date=$$(echo "$$date" | tr / -); echo "src/shizuka.space/glog/$${date}.gmi")

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

$(SHIZ-GLOGDEX): $(SHIZ-GLOGOBJ) Makefile bin/eval-template
	printf '=> / /  Back to capsule home\n\n'>| $@.tmp
	for article in $(SHIZ-GLOGOBJ); do \
	    target=$${article%index.gmi}; \
	    target=$${target#$(BUILD)/shizuka.space/glog/}; \
	    date=$${target%/}; \
	    date=$$(echo "$$date" | tr / -); \
	    heading=$$(sed -ne '/^#/ { s/^#* //p; q; }' < $$article); \
	    printf '=> %s/ %s - %s\n' "$$target" "$$date" "$$heading"; \
	done >> $@.tmp
	mv $@.tmp $@

$(foreach target,$(SHIZ-GLOGOBJ),$(call make-shiz-glog-rule,$(target)))

$(SHIZ-GLOGOBJ):
	mkdir -p $(dir $@)
	bin/eval-template -I src/shizuka.space/BITS < $< > $@.tmp
	printf '\n=> / /  Back to capsule home\n=> /glog/  Back to /glog/\n' >> $@.tmp
	mv $@.tmp $@

.PHONY: clean

clean:
	rm -fr $(BUILD)/*/* stamps
# ^ Leave $(BUILD/$(SITENAME) around, in case build/ is symlinked to
# /var/gemini, etc
