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
import subprocess

base_path = os.path.realpath("%s/../" % os.path.dirname(__file__))

for filename in glob.glob("%s/*.po" % base_path):
    sp = subprocess.run(['/usr/local/bin/msgfmt', '-o', '/dev/null', filename], capture_output=True, text=True)
    broken_lines = {}
    msgfmt_errors = {}
    for line in sp.stderr.split('\n'):
        if line.startswith(filename):
            parts = line.split(':')
            if len(parts) > 2 and parts[1].isdigit():
                idx = int(parts[1])
                broken_lines[idx] = idx
                msgfmt_errors[idx] = line

    if broken_lines:
        print("Found %d broken translations in %s" % (len(broken_lines), filename))
        source_lines = open(filename).read().split('\n')
        # msgfmt displays erros on msgstr, collect and search backwards for the related (input) text
        line_count = len(source_lines)
        for seq, line in enumerate(reversed(source_lines)):
            this_line_id = line_count - seq
            if this_line_id in msgfmt_errors:
                err_line_id = this_line_id
                while line.strip() != '':
                    this_line_id -= 1
                    broken_lines[this_line_id] = err_line_id
                    line = source_lines[this_line_id]

        # write good and bad records to different files
        new_filename = '%s.new' % filename
        orig_filename = "%s.orig" % filename
        failed_filename = '%s.failed' % filename
        if os.path.isfile(new_filename):
            os.remove(new_filename)
        with open(new_filename, 'w') as f_new:
            with open(failed_filename, 'w') as f_failed:
                for seq, line in enumerate(source_lines):
                    if seq in broken_lines:
                        if line.startswith('msgid '):
                            f_failed.write("# > %s\n" % msgfmt_errors[broken_lines[seq]])
                        f_failed.write("%s\n" % line)
                    else:
                        f_new.write("%s\n" % line)
        if os.path.isfile(orig_filename):
            os.remove(orig_filename)
        os.rename(filename, orig_filename)
        os.rename(new_filename, filename)
        print("> %s contains errors" % failed_filename)

