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

sub import {
    my $class = shift;
 
    while ( scalar @_ ) {
        my $type = shift;
        ($type // '') =~ $type_r or _croak_type($type);
        @{"${type}::ISA"} = $class;
        no warnings qw(once);
        %{"${type}::Flags"} = map { $_ => 1 } my @f = ref $_[0]
          ? map { ( ($_ // '') =~ $flag_r)[0] // croak "flag '" . ($_ // '<undef>') . "' is invalid" } @{shift()}
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

sub new {
    my ($type, $message, @flags) = @_;
    '['  . ( (($type // '') =~ $type_r)[0] // croak_type($type) ) .
     '|' . join('|', grep { ${"${type}::Flags"}{$_} or croak "invalid flag '$_', exception type '$type' didn't declare it" } @flags) . '|]' . ($message // '');
}

sub set::flags {
    my (undef, @flags) = @_;
    &{"set::$_"}($_[0]) foreach @flags;
}

sub _croak_type { croak "type '" . ($_[0] // '<undef>') . "' is invalid" }


sub get::flags {
    my ($type, undef, $flags) = ($_[0] // '') =~ $header_r or croak 'Argument is not an StringBased exception';
    sort grep { ${"${type}::Flags"}{$_} or croak "exception string contains invalid flag '$_'" } split(/\|/, $flags);
}

sub possible::flags {
    my ($type) = ($_[0] // '') =~ $header_r;
    $type //= $_[0] // '';

    ($type // 'NotAValidClass')->isa('Exception::StringBased')
      or croak 'Argument is not a StringBased exception or a StringBased class';
    sort keys %{"${type}::Flags"};
}

#sub flags::list {
#    my $type = ( ($_[0] // '' ) =~ $header_r)[0] // croak 'Argument is not an StringBased exception';
#    split('|', sort keys %{"${type}::Flags"};
#}





sub raise($;@) {
    my ($type, @flags) = @_;
    my $string = '[|' . join('|', @_) . '|]';
    print  "$string\n";

}


# sub exception::isa {
#     my ($e, $type) = @_;
#     ${$type}
#       or croak "";
#     ( ($e =~$header_r)[0] // return '') eq $type;
# }


1;

# sub

#     my $version_name = 'VERSION';
 
#     my $code = <<"EOPERL";
# package $subclass;
 
# use base qw($isa);
 
# our \$$version_name = '1.1';
 
# 1;
 
# EOPERL
 
#     if ( $def->{description} ) {
#         ( my $desc = $def->{description} ) =~ s/([\\\'])/\\$1/g;
#         $code .= <<"EOPERL";
# sub description
# {
#     return '$desc';
# }
# EOPERL
#     }
 
#     my @fields;
#     if ( my $fields = $def->{fields} ) {
#         @fields = UNIVERSAL::isa( $fields, 'ARRAY' ) ? @$fields : $fields;
 
#         $code
#             .= "sub Fields { return (\$_[0]->SUPER::Fields, "
#             . join( ", ", map { "'$_'" } @fields )
#             . ") }\n\n";
 
#         foreach my $field (@fields) {
#             $code .= sprintf( "sub %s { \$_[0]->{%s} }\n", $field, $field );
#         }
#     }
 
#     if ( my $alias = $def->{alias} ) {
#         die "Cannot make alias without caller"
#             unless defined $Exception::Class::Caller;
 
#         no strict 'refs';
#         *{"$Exception::Class::Caller\::$alias"}
#             = sub { $subclass->throw(@_) };
#     }
 
#     if ( my $defaults = $def->{defaults} ) {
#         $code
#             .= "sub _defaults { return shift->SUPER::_defaults, our \%_DEFAULTS }\n";
#         no strict 'refs';
#         *{"$subclass\::_DEFAULTS"} = {%$defaults};
#     }
 
#     eval $code;
 
#     die $@ if $@;
 
#     $CLASSES{$subclass} = 1;
# }
