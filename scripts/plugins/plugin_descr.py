"""
    Copyright (c) 2015 Deciso B.V.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
    OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.

    --------------------------------------------------------------------------------------

    package : translate
    function: collect acl translatable text
"""
__author__ = 'Ad Schellevis'

def getTranslations(root):

    rootpath = root[:-4]
    comment = ''
    maintainer = ''
    for line in open('%s/Makefile' % rootpath):
        split = line.split('=')
        if len(split) == 2 and split[0] == 'PLUGIN_COMMENT':
            comment = split[1].strip()
        if len(split) == 2 and split[0] == 'PLUGIN_MAINTAINER':
            maintainer = split[1].strip()

    if comment != '':
        yield comment

    try:
        yield '%s\n\n%s\n\nMaintainer: %s' % (comment, open('%s/pkg-descr' % rootpath).read(), maintainer)
    except IOError:
        pass
