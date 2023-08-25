#!/usr/bin/env python3

"""
    Copyright (c) 2023 Deciso B.V.
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
"""
import glob
import os
import sys
import requests

project_id = 179921
base_path = os.path.realpath("%s/../" % os.path.dirname(__file__))
api_filename = "%s/poeditor.apikey" % base_path

if os.path.isfile(api_filename):
    api_key = open(api_filename).read().strip()
else:
    print("api key missing (%s)" % api_filename)
    sys.exit(-1)

r = requests.post('https://poeditor.com/api/', {
    'api_token': api_key,
    'action': 'list_languages',
    'id': project_id
}).json()

if 'response' in r and 'list' in r:
    targets = {}
    for filename in glob.glob("%s/*.po" % base_path):
        tmp = os.path.basename(filename)
        if tmp == 'pt_BR.po':
            targets['pt-br'] = filename
        else:
            targets[tmp.split('_')[0]] = filename
    for lang in r['list']:
        code = lang['code'].split('-')[0]
        if lang['code'] == 'pt-br':
            code = lang['code'];
        if code not in targets:
            print("Skipped %(code)s (percentage complete : %(percentage).2f)" % lang)
        else:
            lang['target_filename'] =  targets[code]
            r = requests.post('https://poeditor.com/api/', {
                'api_token': api_key,
                'action': 'export',
                'id': project_id,
                'language': lang['code'],
                'type': 'po'
            }).json()
            with open(lang['target_filename'], 'w') as f_out:
                f_out.write(requests.get(r['item']).text)
            print("Downloaded %(code)s to %(target_filename)s (percentage complete : %(percentage).2f)" % lang)

