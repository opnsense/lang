OPNsense language translation kit
=================================

The kit requires additional tools in order to properly extract strings
from the source code.  You'll need to run this once locally:

    # pkg install gettext-tools p5-Locale-Maketext-Lexicon python37

Regenerate source strings that cannot be found in the template
generation step (XML contents, etc.):

    # make src

Regenerate the translation template using:

    # make template

Merge the latest template changes into the actual translations:

    # make merge

Remove the compiled translation files from the system/chroot:

    # make clean

The build system will automatically pick up all registered languages.

Translation guidelines
======================

* Translation platform POEditor can be found under https://translate.opnsense.org/
* Translations should be suggestions, and if you see suggestions either confirm them or change them. We can always change the strings more than once.
* Translations that need further work are better than no translations. Don't be shy. :)
* Punctuation and spacing should be kept as in the original string even though it looks stupid. Strings like "test: 1234" should not be translated to "test : 1234". Same goes for parentheses, etc.
* Errors in original strings should be brought up to project@ or franco@ or recorded in github issues so they can be fixed in the code. These original string fixes take time to get to back into POEditor. It's more important they are fixed in the code then to translate the faulty ones.
* If you feel the context is ambiguous or unclear, please reporte the strings
* HTML in strings should be reported as well.
* If you find you have to reorder dynamic arguments like "test %s is %s", you can use "is %2$s test %1$s", In this case all arguments must be numbered.
* We are going to pull in translations directly from POEditor just before a release so as long as you use POEditor to translate your progress will automatically be merged.
