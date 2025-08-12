# Copyright (c) 2015-2023 Franco Fichtner <franco@opnsense.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

XGETTEXT=	xgettext -L PHP --from-code=UTF-8 -F --strict --debug
XGETTEXT_PL=	xgettext.pl -P Locale::Maketext::Extract::Plugin::Volt \
		-u -w -W
MSGFMT=		msgfmt

PERL_DIR=	/usr/local/lib/perl5/site_perl
PERL_NAME=	Locale/Maketext/Extract/Plugin

LOCALEDIR=	/usr/local/share/locale/%%LANG%%/LC_MESSAGES

LANGUAGES+=	cs_CZ
LANGUAGES+=	de_DE
LANGUAGES+=	el_GR
LANGUAGES+=	es_ES
LANGUAGES+=	fr_FR
LANGUAGES+=	it_IT
LANGUAGES+=	ja_JP
LANGUAGES+=	ko_KR
LANGUAGES+=	no_NO
LANGUAGES+=	pl_PL
LANGUAGES+=	pt_BR
LANGUAGES+=	pt_PT
LANGUAGES+=	ru_RU
LANGUAGES+=	tr_TR
LANGUAGES+=	vi_VN
LANGUAGES+=	zh_CN
LANGUAGES+=	zh_TW

PLUGINSDIR?=	/usr/plugins
COREDIR?=	/usr/core
LANGDIR?=	/usr/lang

TEMPLATE=	en_US
INSTALL=
TEST=

PAGER?=		less

all:
	@cat ${.CURDIR}/README.md | ${PAGER}

.for LANG in ${LANGUAGES}
${LANG}DIR=	${LOCALEDIR:S/%%LANG%%/${LANG}/g}

install-${LANG}:
	@mkdir -p ${DESTDIR}${${LANG}DIR}
	${MSGFMT} --strict -o ${DESTDIR}${${LANG}DIR}/OPNsense.mo ${LANG}.po

clean-${LANG}:
	@rm -f ${DESTDIR}${${LANG}DIR}/OPNsense.mo

test-${LANG}:
	${MSGFMT} -o /dev/null ${LANG}.po
	# XXX pretty this up
	@echo $$(grep -c ^msgid ${LANG}.po) / $$(grep -c ^msgstr ${LANG}.po)

INSTALL+=	install-${LANG}
CLEAN+=		clean-${LANG}
TEST+=		test-${LANG}
.endfor

_PLUGINSDIRS!=	if [ -d ${PLUGINSDIR} ]; then \
			${MAKE} -C ${PLUGINSDIR} -v PLUGIN_DIRS \
			    PLUGIN_PHP=ignore PLUGIN_PYTHON=ignore; \
		fi
PLUGINSDIRS=	${_PLUGINSDIRS:S/^/${PLUGINSDIR}\//g}

${TEMPLATE}:
	@cp ${.CURDIR}/Volt.pm ${PERL_DIR}/${PERL_NAME}/
	@: > ${TEMPLATE}.pot
.for ROOTDIR in ${PLUGINSDIRS} ${COREDIR} ${LANGDIR}
	@if [ -d ${ROOTDIR}/src ]; then \
		echo ">>> Scanning ${ROOTDIR}"; \
		${XGETTEXT_PL} -D ${ROOTDIR}/src -p ${.CURDIR} -o ${TEMPLATE}.pot; \
		find ${ROOTDIR}/src -type f -print0 | \
		    xargs -0 ${XGETTEXT} -j -o ${.CURDIR}/${TEMPLATE}.pot; \
	fi
.endfor

template: ${TEMPLATE}
install upgrade: ${INSTALL}
clean: ${CLEAN}
test: ${TEST}

src:
	@${.CURDIR}/Scripts/collect.py ${PLUGINSDIRS} ${COREDIR}

fetch:
	@${.CURDIR}/Scripts/fetch_po_files.py

cleanse:
	@${.CURDIR}/Scripts/cleanse_po.py

bootstrap:
	@pkg install gettext-tools p5-Locale-Maketext-Lexicon python3


.PHONY: ${INSTALL} ${TEMPLATE} src
