OPNsense language translation kit
=================================

The kit requires additional tools in order to properly extract strings
from the source code.  You'll need to run this once locally:

    # pkg install gettext-tools p5-Locale-Maketext-Lexicon python39
    # cd /usr/local/bin && ln -sfn python3.9 python3

Fetch the latest translations (having set up poeditor.apikey file):

    # make fetch

Test the updated translations for errors or run a cleanup if necessary:

    # make test
    # make cleanse

At this point a release can be tagged and used for building a new language
package via ports.git/opnsense/lang port.

In order to get new strings into the template the source strings that cannot
be found in the template generation step (XML contents, etc.) must be executed
first:

    # make src

Regenerate the translation template using:

    # make template

The POT file can be uploaded at this point. Then merge the latest template
changes into the actual translations by using fetch again:

    # make fetch

Remove the compiled translation files from the system/chroot:

    # make clean

Translation guidelines
======================

* Translation platform POEditor can be found under https://translate.opnsense.org/
* Translations that need further work are better than no translations. Do not be shy. :)
* Languages translated under 30% are considered development only.
* Punctuation and spacing should be kept as in the original string even though it looks stupid. Strings like "test: 1234" should not be translated to "test : 1234". Same goes for parentheses, etc.
* Errors in original strings should be brought up by comment so they can be fixed in the code. These original string fixes take time to get to back into POEditor. It is more important they are fixed in the code than to translate the faulty ones.
* If you feel the context is ambiguous or unclear, please report the strings
* HTML in strings should be reported as well.
* If you find you have to reorder dynamic arguments like "test %s is %s", you can use "is %2$s test %1$s", In this case all arguments must be numbered.
* We are going to pull in translations directly from POEditor just before a release so as long as you use POEditor to translate your progress will automatically be merged.
* Since mixed forms like "interface(s)" cannot be avoided in the English translation template for historic reasons, translators should try to treat them as plurals without parenthesis.
