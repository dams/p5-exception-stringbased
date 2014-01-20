# ABSTRACT: Fast and lightweight Perl client for Riak

package Exception::StringBased;

sub import {
    my $class = shift;
 
    while ( my $subclass = shift ) {
        my $def = ref $_[0] ? shift : {};

        

    }
}


    my $version_name = 'VERSION';
 
    my $code = <<"EOPERL";
package $subclass;
 
use base qw($isa);
 
our \$$version_name = '1.1';
 
1;
 
EOPERL
 
    if ( $def->{description} ) {
        ( my $desc = $def->{description} ) =~ s/([\\\'])/\\$1/g;
        $code .= <<"EOPERL";
sub description
{
    return '$desc';
}
EOPERL
    }
 
    my @fields;
    if ( my $fields = $def->{fields} ) {
        @fields = UNIVERSAL::isa( $fields, 'ARRAY' ) ? @$fields : $fields;
 
        $code
            .= "sub Fields { return (\$_[0]->SUPER::Fields, "
            . join( ", ", map { "'$_'" } @fields )
            . ") }\n\n";
 
        foreach my $field (@fields) {
            $code .= sprintf( "sub %s { \$_[0]->{%s} }\n", $field, $field );
        }
    }
 
    if ( my $alias = $def->{alias} ) {
        die "Cannot make alias without caller"
            unless defined $Exception::Class::Caller;
 
        no strict 'refs';
        *{"$Exception::Class::Caller\::$alias"}
            = sub { $subclass->throw(@_) };
    }
 
    if ( my $defaults = $def->{defaults} ) {
        $code
            .= "sub _defaults { return shift->SUPER::_defaults, our \%_DEFAULTS }\n";
        no strict 'refs';
        *{"$subclass\::_DEFAULTS"} = {%$defaults};
    }
 
    eval $code;
 
    die $@ if $@;
 
    $CLASSES{$subclass} = 1;
}
