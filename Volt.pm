package Locale::Maketext::Extract::Plugin::Volt;
$Locale::Maketext::Extract::Plugin::Volt::VERSION = '1.00';
use strict;
use base qw(Locale::Maketext::Extract::Plugin::Base);

# ABSTRACT: Volt template parser


sub file_types {
    return qw( volt );
}

sub extract {
    my $self = shift;
    local $_ = shift;

    my $line = 1;

    # Volt Template: collect single-quoted translations
    pos($_) = 0;
    while (m/\G(.*?(?<!\{)\{\{(?!\{).*?[:]?\s*?lang\._\(\s*'((?:[^\\']|\\.)*?)'\)\s*?[,\]]?.*?\|?.*?\}\})/sg) {
        my ( $vars, $str ) = ( '', $2 );
        # escaped single-qutes must be unescaped now
        $str =~ s/\\'/'/g;
        $line += ( () = ( $1 =~ /\n/g ) );    # cryptocontext!
        $self->add_entry( $str, $line, $vars );
    }

    # Lint Pass: warn about double-quoted translations
    $line = 1;
    pos($_) = 0;
    while (m/\G(.*?(?<!\{)\{\{(?!\{).*?[:]?\s*?lang\._\(\s*")/sg) {
        $line += ( () = ( $1 =~ /\n/g ) );    # cryptocontext!
        say STDERR "???: $line: Ignored double-quoted string";
    }
}

1;

__END__
