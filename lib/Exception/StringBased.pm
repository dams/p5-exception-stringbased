# ABSTRACT: Exception modules where exceptions are not objects but simple strings.

package Exception::StringBased;
use strict;
use warnings;

use Carp;

# regexp to extract header's type and flags
my $header_r = qr/\[([^]]+)(\|[^]]*\|)\]/;

sub import {
    my $class = shift;
 
    while ( my $type = shift ) {
        no strict 'refs';
        @{"${type}::ISA"} = $class;
        no warnings qw(once);
        %{"${type}::Flags"} = map { $_ => 1 } my @f = ref $_[0] ? @{shift()} : ();
        foreach my$f (@f) {
            my $match = "|$f|";
            *{"flag::$f"} = sub {
                my ( $type, $flags ) = $_[0] =~ $header_r;
                ${"${type}::Flags"}{$f}
                  or croak qq(Can't locate object method "$f" via package "flag");
                index($flags, $match) >= 0;
            };
        }
    }
}

sub new {
    '[' . shift . '|' . join('|', @_) . '|]';
}

sub raise($;@) {
    my $string = '[|' . join('|', @_) . '|]';
    print  "$string\n";

}

sub Exception::is {
    my $e = @_;
    extract_header($e) =~ /::/
}

sub extract_header {
    $_[0] =~ /\[:[^]].+:\]/;
}

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
