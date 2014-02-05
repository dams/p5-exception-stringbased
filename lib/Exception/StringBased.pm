# ABSTRACT: Exception modules where exceptions are not objects but simple strings.

package Exception::StringBased;
use strict;
use warnings;
use 5.10.0;

use Carp;

# regexp to extract header's type and flags
my $header_r = qr/\[([^]|]+)(\|([^]]*)\|)\]/;
my $type_r = qr/^([^|\s0-9][^|\s]*)$/;
my $flag_r = qr/^([^|\s0-9][^|\s]*)$/;

no strict 'refs';
no warnings qw(once);

my %registered;

sub import {
    my $class = shift;
 
    while ( scalar @_ ) {
        my $type = shift;
        ($type // '') =~ $type_r or _croak(type => $type);
        $registered{$type} = 1;
        @{"${type}::ISA"} = $class;
        %{"${type}::Flags"} = map { $_ => 1 } my @f = ref $_[0]
          ? map { ( ($_ // '') =~ $flag_r)[0] // _croak(flag => $_) } @{shift()}
          : ();
        foreach my $f (@f) {
            my $match = "|$f|";
            *{"has::$f"} = sub {
                my ($type, $flags) = $_[0] =~ $header_r;
                ${"${type}::Flags"}{$f}
                  or croak qq(Can't locate object method "$f" via package "set");
                index($flags, $match) >= 0;
            };
            *{"set::$f"} = sub {
                my ($type, $flags) = $_[0] =~ $header_r;
                ${"${type}::Flags"}{$f}
                  or croak qq(Can't locate object method "$f" via package "has");
                index($flags, $match) >= 0
                  and return 1;
                $flags =~ s/^\|\|$/|/;
                $_[0] =~ s/$header_r/[$type$flags$f|]/;
                return $_[0];
            };
        }
    }
}

sub _croak { croak $_[0] . " '" . ($_[1] // '<undef>') . "' is invalid" }

# Class methods

sub new {
    my ($type, $message, @flags) = @_;
    $registered{$type} or croak "exception type '$type' has not been registered yet";
    '[' . $type . '|' . join('|', grep { ${"${type}::Flags"}{$_} or croak "invalid flag '$_', exception type '$type' didn't declare it" } @flags) . '|]' . ($message // '');
}

sub raise { croak shift->new(@_)}
sub throw { croak shift->new(@_)}

# fake methods

sub set::flags {
    my (undef, @flags) = @_;
    &{"set::$_"}($_[0]) foreach @flags;
    $_[0];
}

sub get::flags {
    my ($type, undef, $flags) = ($_[0] // '') =~ $header_r
      or croak 'Argument is not an StringBased exception';
    sort grep {
        ${"${type}::Flags"}{$_} or croak "exception string contains invalid flag '$_'"
    } split(/\|/, $flags);
}

sub possible::flags {
    my ($type) = ($_[0] // '') =~ $header_r;
    $type //= $_[0] // '';
    ($type // 'NotAValidClass')->isa(__PACKAGE__)
      or croak 'Argument is not a StringBased exception or a StringBased class';
    sort keys %{"${type}::Flags"};
}

sub get::type {
    my ($type) = ($_[0] // '') =~ $header_r
      or croak 'Argument is not an StringBased exception';
    $type;
}

sub is::a {
    my ($type) = ($_[0] // '') =~ $header_r
      or croak 'Argument is not an StringBased exception';
    $type->isa($_[1]);
}


1;

