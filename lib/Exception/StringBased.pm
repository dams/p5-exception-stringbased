# ABSTRACT: a Perl Exceptions module where exceptions are not objects but simple strings.

package Exception::StringBased;
use strict;
use warnings;
use 5.10.0;

use Carp;


=head1 SYNOPSIS

  use Exception::StringBased (
    'MyException',
    'ExceptionWithFlag' => [ qw(flag1 flag2 flag3) ],
  );

use Try::Tiny;
 
try {
    MyException->throw( 'I feel funny.', 'flag1' );
}
catch {
    die $_ unless $_->is::an::exception;
 
    if ( $_->is::of::type('ExceptionWithFlag') ) {
        warn "we got this exception saying " . $_->get::message();
        $_->has::flag1
          and warn "the exception has flag1 set";
        warn "these arethe flags that this exception has: " . join(", ", $_->get::flags);
        warn "these is the flags that this exception has registered: " . join(", ", $_->possible::flags);
        exit;
    }
    else {
        $_->throw::again;
    }
};

=head1 DESCRIPTION

This module allows you to declare exceptions, and provides a simple interface
to declare, throw, and interact with them. It can be seen as a very light
version of C<Exception::Class>, except that there is a catch: exceptions are
B<not objects>, they are B<normal strings>, with a header that contains properties

=head1 WHY WOULD YOU WANT SUCH THING ?

Having exceptions be objects is sometimes very annoying. What if some code is
calling you, and isn't expecting objects exceptions ? Sometimes string
overloading doesn't work. Sometimes, external code tamper with your exception.
Consider:

  use Exception::Class ('MyException');
  use Scalar::Util qw( blessed );
  use Try::Tiny;

  $SIG{__DIE__} = sub { die "FATAL: $_[0]" };

  try {
    MyException->throw("foo");
  } catch {
    die "this is not a Class::Exception" unless blessed $_ && $_->can('rethrow');
    if ($_->isa('MyException')) { ... }
  };

In this example, the exception thrown is a C<Class::Exception> instance, but it
gets forced to a string by the signal handler. When in the catch block, it's
not an object, it's a regular string, and the code fails to see that it's a
'MyException'.

=head1 BUT THIS NEVER HAPPENS

Well, don't use this module then :)

=head1 BASIC USAGE

=head2 Declaring exception types

=head2 throwing exceptions

=head2 catching and checking exceptions

=head1 CLASS METHODS

=head1 METHODS

=cut

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

sub get::message {
    $_[0] =~ s/$header_r//r
      or croak 'Argument is not an StringBased exception';
}

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

sub is::of::type {
    my ($type) = ($_[0] // '') =~ $header_r
      or croak 'Argument is not an StringBased exception';
    $type->isa($_[1]);
}

sub is::an::exception {
    my ($type) = ($_[0] // '') =~ $header_r
      or return '';
    $type->isa(__PACKAGE__);
}

sub throw::again { die $_[0] }

1;

