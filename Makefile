# This file compiles Javascript to Java bytecode for Markdown conversion
# and sanitization, and compiles Java interfaces to the generated bytecode.

# The Javascript file debiki-pagedown.min.js is concatenated and minified
# by Grunt.js.

DESTDIR=target/scala-2.10/compiledjs-classes/
CLASSDIR=${DESTDIR}compiledjs/
HTML_SANITIZER_JS=client/vendor/html-sanitizer-bundle.js
PAGEDOWN_JS=public/res/debiki-pagedown.js
# RHINOJAR=target/js-1.7R2.jar
RHINOJAR=target/rhino1_7R2/js.jar

SBT_CLASSDIR_ROOT=target/scala-2.10/classes/

help:
	@echo Open the Makefile and read it.

# Compile Javascript to Java bytecode, using Mozilla Rhino.
# ------------------------------------
# There're some duplicated rules unfortunately.

compile_javascript: \
		${CLASSDIR}HtmlSanitizerJsImpl.class \
		${CLASSDIR}PagedownJsImpl.class \
		silly_copy_to_sbt_classdir


# Compile Javascript files.
# ------------------------------------

${CLASSDIR}HtmlSanitizerJsImpl.class: ${CLASSDIR}HtmlSanitizerJs.class ${RHINOJAR} ${HTML_SANITIZER_JS}
	java -cp ${RHINOJAR}:${DESTDIR} \
	  org.mozilla.javascript.tools.jsc.Main \
	  -opt 9 \
	  -implements compiledjs.HtmlSanitizerJs \
	  -package compiledjs \
	  -d ${DESTDIR} \
	  -o HtmlSanitizerJsImpl \
	  ${HTML_SANITIZER_JS}

${CLASSDIR}PagedownJsImpl.class: ${CLASSDIR}PagedownJs.class ${RHINOJAR} ${PAGEDOWN_JS}
	java -cp ${RHINOJAR}:${DESTDIR} \
	  org.mozilla.javascript.tools.jsc.Main \
	  -opt 9 \
	  -implements compiledjs.PagedownJs \
	  -package compiledjs \
	  -d ${DESTDIR} \
	  -o PagedownJsImpl \
	  ${PAGEDOWN_JS}

# Warning: Duplicated rule. A corresponding rule is also present in the Gruntfile. Keep in sync.
${PAGEDOWN_JS}: modules/pagedown/Markdown.Converter.js client/compiledjs/PagedownJavaInterface.js
	# Grunt merges Javascript files from ./client/ to ./public/.
	grunt

${RHINOJAR}:
	wget -O target/rhino1_7R2.zip ftp://ftp.mozilla.org/pub/mozilla.org/js/rhino1_7R2.zip
	unzip target/rhino1_7R2.zip -d target


# Compile Java interfaces to Javascript files.
# ------------------------------------

HtmlSanitizerJs: ${CLASSDIR}HtmlSanitizerJs.class
${CLASSDIR}HtmlSanitizerJs.class: app/compiledjs/HtmlSanitizerJs.java
	mkdir -p ${DESTDIR}
	javac $< -d ${DESTDIR}

PagedownJs: ${CLASSDIR}PagedownJs.class
${CLASSDIR}PagedownJs.class: app/compiledjs/PagedownJs.java
	mkdir -p ${DESTDIR}
	javac $< -d ${DESTDIR}


# Ensure compiled files are included in generated JARs.
# ------------------------------------

silly_copy_to_sbt_classdir: \
		${CLASSDIR}HtmlSanitizerJsImpl.class \
		${CLASSDIR}PagedownJsImpl.class
	cp -a ${DESTDIR}compiledjs ${SBT_CLASSDIR_ROOT}

# ------------------------------------

cleanjs:
	rm -f ${CLASSDIR}PagedownJs.class ${CLASSDIR}HtmlSanitizerJs.class
	rm -f ${CLASSDIR}PagedownJsImpl.class ${CLASSDIR}HtmlSanitizerJsImpl.class
	rm -f ${CLASSDIR}PagedownJsImpl1.class ${CLASSDIR}HtmlSanitizerJsImpl1.class


clean: cleanjs

.PHONY: cleanjs clean

# vim: list
