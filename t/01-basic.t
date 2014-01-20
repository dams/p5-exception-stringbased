#!perl

use strict;
use warnings;

use Test::More;

use Exception::StringBased (
    'PermissionException',
    'Permission2Exception' => { flags => [ qw(Frontend Login Password) ] }
);


 
    'AnotherException' => [ qw( Retryable) ],

    'YetAnotherException' => {
        isa         => 'AnotherException',
        description => 'These exceptions are related to IPC'
    },
 
    'ExceptionWithFields' => {
        isa    => 'YetAnotherException',
        fields => [ 'grandiosity', 'quixotic' ],
        alias  => 'throw_fields',
    },
);



MyException->throw("Invalid password")

my $e = Exception::new->()
raise
Exception::raise
