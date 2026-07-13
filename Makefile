BUILD = build

FAIL-SRC := $(shell find src/the.web-is.fail ! -type d | grep -v BITS)
FAIL-OBJS := $(patsubst src/%,$(BUILD)/%,$(FAIL-SRC))

SHIZ-STATIC-SRC := $(filter-out src/shizuka.space/index.gmi,$(shell find src/shizuka.space ! -type d | grep -v BITS | grep -v glog/))
SHIZ-STATIC-OBJS := $(patsubst src/%,$(BUILD)/%,$(SHIZ-STATIC-SRC))
SHIZ-GLOGSRC := $(shell find src/shizuka.space/glog ! -type d | grep -v BITS)
SHIZ-GLOGOBJ := $(foreach obj,$(SHIZ-GLOGSRC),$(shell obj=$(obj); obj=build/$${obj#src/}; date=$${obj##*/}; date=$${date%.gmi}; date=$$(echo "$$date" | tr - /); echo "$(BUILD)/shizuka.space/glog/$${date}/index.gmi"))
SHIZ-GLOG-LATEST := $(BUILD)/shizuka.space/glog/latest/index.gmi

FHTML-OBJS := $(subst $(BUILD)/the.web-is.fail/,$(BUILD)/the.web-is.fail-html/,$(FAIL-OBJS))
FHTML-HTML := $(patsubst $(BUILD)/the.web-is.fail/%.gmi,$(BUILD)/the.web-is.fail-html/%.html,$(filter %.gmi,$(FAIL-OBJS)))
FHTML-MISC := $(patsubst $(BUILD)/the.web-is.fail/%,$(BUILD)/the.web-is.fail-html/%,$(filter-out %.gmi,$(FAIL-OBJS)))

define make-shiz-glog-rule
$(1): $(call make-shiz-glog-src,$(1)) Makefile bin/eval-template

endef
make-shiz-glog-src = $(shell date=$1; date=$${date#$(BUILD)/shizuka.space/glog/}; date=$${date%/index.gmi}; date=$$(echo "$$date" | tr / -); echo "src/shizuka.space/glog/$${date}.gmi")

define make-fail-html-rule
$(patsubst $(BUILD)/the.web-is.fail/%.gmi,$(BUILD)/the.web-is.fail-html/%.html,$(1)): $(1) Makefile bin/htmlify
	mkdir -p $$(dir $$@)
	bin/htmlify -v me=$$< < $$< > $$@.tmp
	mv $$@.tmp $$@

endef

define make-fail-html-static-rule
$(patsubst $(BUILD)/the.web-is.fail/%,$(BUILD)/the.web-is.fail-html/%,$(1)): $(1) Makefile
	mkdir -p $$(dir $$@)
	cp $$< $$@

endef

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

stamps/sites: stamps stamps/the.web-is.fail stamps/shizuka.space stamps/the.web-is.fail-html
	touch $@

stamps:
	mkdir -p stamps

stamps/the.web-is.fail: $(FAIL-OBJS)
	touch $@

stamps/shizuka.space: stamps/shizuka.space-static stamps/shizuka.space-glog
	touch $@

stamps/the.web-is.fail-html: $(FHTML-HTML) $(FHTML-MISC) $(BUILD)/the.web-is.fail-html/style.css

$(BUILD)/the.web-is.fail-html/style.css: src/style.css Makefile
	cp $< $@

stamps/shizuka.space-static: $(BUILD)/shizuka.space/index.gmi $(SHIZ-STATIC-OBJS)
	touch $@

$(eval $(foreach gmi,$(filter %.gmi,$(FAIL-OBJS)),$(call make-fail-html-rule,$(gmi))))

$(eval $(foreach other,$(filter-out %.gmi,$(FAIL-OBJS)),$(call make-fail-html-static-rule,$(other))))

$(SHIZ-STATIC-OBJS): $(BUILD)/%.gmi: src/%.gmi src/shizuka.space/BITS/*.gmi Makefile bin/eval-template
	mkdir -p $(dir $@)
	bin/eval-template -I src/shizuka.space/BITS < $< > $@.tmp
	mv $@.tmp $@

stamps/shizuka.space-glog: $(SHIZ-GLOGOBJ)

#$(SHIZ-GLOG-LATEST): $(SHIZ-GLOGOBJ) Makefile bin/eval-template
$(BUILD)/shizuka.space/index.gmi: src/shizuka.space/index.gmi $(SHIZ-GLOGOBJ) Makefile bin/eval-template
	mkdir -p $(dir $@)
	bin/eval-template -I src/shizuka.space/BITS < $< > $@.tmp
	printf '\n###Latest glogs:\n\n' >> $@.tmp
	for article in $(SHIZ-GLOGOBJ); do \
	    echo "$$article"; \
	done | sort -r | head -n 10 | while read -r article; do \
	    target=$${article%index.gmi}; \
	    target=$${target#$(BUILD)/shizuka.space/glog/}; \
	    date=$${target%/}; \
	    date=$$(echo "$$date" | tr / -); \
	    heading=$$(sed -ne '/^#/ { s/^#* //p; q; }' < $$article); \
	    printf '=> %s/ %s - %s\n' "/glog/$$target" "$$date" "$$heading"; \
	done >> $@.tmp
	printf '\n--\n=> mailto:kado@shizuka.space?subject=%s kado@shizuka.space (please include SHIZUKA in the subject)\n' 'SHIZUKA%3A%20%28Replace%20Me%21%29' >> $@.tmp
	mv $@.tmp $@

$(eval $(foreach target,$(SHIZ-GLOGOBJ),$(call make-shiz-glog-rule,$(target))))

$(SHIZ-GLOGOBJ):
	mkdir -p $(dir $@)
	bin/eval-template -I src/shizuka.space/BITS < $< > $@.tmp
	printf '\n=> / /  Back to capsule home\n' >> $@.tmp
	printf '\n--\n=> mailto:kado@shizuka.space?subject=%s kado@shizuka.space (please include SHIZUKA in the subject)\n' 'SHIZUKA%3A%20%28Replace%20Me%21%29' >> $@.tmp
	mv $@.tmp $@

.PHONY: clean

clean:
	rm -fr $(BUILD)/*/* stamps
# ^ Leave $(BUILD/$(SITENAME) around, in case build/ is symlinked to
# /var/gemini, etc
