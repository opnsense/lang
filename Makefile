# Copyright (c) 2015-2016 Franco Fichtner <franco@opnsense.org>
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
MSGMERGE=	msgmerge -U -N --backup=off
MSGFMT=		msgfmt

PERL_DIR=	/usr/local/lib/perl5/site_perl
PERL_NAME=	Locale/Maketext/Extract/Plugin

LOCALEDIR=	/usr/local/share/locale/%%LANG%%/LC_MESSAGES

LANGUAGES+=	cs_CZ
LANGUAGES+=	de_DE
LANGUAGES+=	es_ES
LANGUAGES+=	fr_FR
LANGUAGES+=	it_IT
LANGUAGES+=	nl_NL
LANGUAGES+=	ja_JP
LANGUAGES+=	mn_MN
LANGUAGES+=	pt_BR
LANGUAGES+=	ru_RU
LANGUAGES+=	sv_SE
LANGUAGES+=	tr_TR
LANGUAGES+=	zh_CN

PLUGINSDIR?=	/usr/plugins
COREDIR?=	/usr/core
LANGDIR?=	/usr/lang

TEMPLATE=	en_US
INSTALL=
MERGE=
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

merge-${LANG}:
	${MSGMERGE} ${LANG}.po ${TEMPLATE}.pot
	# strip stale translations
	sed -i '' -e '/^#~.*/d' ${LANG}.po

test-${LANG}:
	${MSGFMT} -o /dev/null ${LANG}.po

INSTALL+=	install-${LANG}
CLEAN+=		clean-${LANG}
MERGE+=		merge-${LANG}
TEST+=		test-${LANG}
.endfor

_PLUGINSDIRS!=	${MAKE} -C ${PLUGINSDIR} list
PLUGINSDIRS=	${_PLUGINSDIRS:S/^/${PLUGINSDIR}\//g}

${TEMPLATE}:
	@cp ${.CURDIR}/Volt.pm ${PERL_DIR}/${PERL_NAME}/
	@: > ${TEMPLATE}.pot
.for ROOTDIR in ${PLUGINSDIRS} ${COREDIR} ${LANGDIR}
	${XGETTEXT_PL} -D ${ROOTDIR}/src -p ${.CURDIR} -o ${TEMPLATE}.pot
	find ${ROOTDIR}/src -print0 | \
	    xargs -0 ${XGETTEXT} -j -o ${.CURDIR}/${TEMPLATE}.pot
.endfor

template: ${TEMPLATE}
install: ${INSTALL}
clean: ${CLEAN}
merge: ${MERGE}
test: ${TEST}

src:
	@${.CURDIR}/scripts/collect.py ${PLUGINSDIRS} ${COREDIR}

.PHONY: ${INSTALL} ${MERGE} ${TEMPLATE} src
