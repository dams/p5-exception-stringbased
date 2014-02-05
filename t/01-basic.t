#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Exception::StringBased (
  PermissionException => [ qw(login password) ],
  'PermissionException2',
);

# test the import
is( exception { Exception::StringBased->import() },
     undef,
     "no types is good" );

like( exception { Exception::StringBased->import(undef) },
      qr/type '<undef>' is invalid/,
      "dies when type undef" );

like( exception { Exception::StringBased->import('1plop') },
      qr/type '1plop' is invalid/,
      "dies when type starts with number" );

like( exception { Exception::StringBased->import('|plop') },
      qr/type '|plop' is invalid/,
      "dies when type contains |" );

like( exception { Exception::StringBased->import('pl op') },
      qr/type 'pl op' is invalid/,
      "dies when type contains space" );

like( exception { Exception::StringBased->import(Foo => ['1plop']) },
      qr/flag '1plop' is invalid/,
      "dies when flag starts with number" );

like( exception { Exception::StringBased->import(Foo => ['|plop']) },
      qr/flag '\|plop' is invalid/,
      "dies when flag contains |" );

like( exception { Exception::StringBased->import(Foo => ['pl op']) },
      qr/flag 'pl op' is invalid/,
      "dies when flag contains space" );


is_deeply( \%PermissionException::Flags,
           { login => 1,
             password => 1,
           },
           "flags have been properly declared" );

{
    my $e = PermissionException->new('This is the text');
    is($e, '[PermissionException||]This is the text', "exception without flags looks good");
    is_deeply([$e->get::flags()], [], "exception contains no flags");
    is_deeply([$e->possible::flags], [qw(login password)], "listing possible flags");
    is_deeply([PermissionException->possible::flags], [qw(login password)], "possible flags");
    ok($e->is::a('PermissionException'), "exception isa PermissionException");
    is($e->get::type(), 'PermissionException', "exception type is ok");
    ok(! $e->is::a('PermissionException2'), "exception is not a PermissionException2");
    ok($e->is::a('Exception::StringBased'), "exception is a Exception::StringBased");
}

{
    my $e = PermissionException->new('This is the text')
      ->set::login
      ->set::password;
    is($e, '[PermissionException|login|password|]This is the text', "exception + flags looks good");
    is_deeply([$e->get::flags()], [qw(login password)], "exception contains the right flags");
}

{
    my $e = PermissionException->new('This is the text');
    $e->set::flags(qw(login password));
    is($e, '[PermissionException|login|password|]This is the text', "exception + flags looks good");
    is_deeply([$e->get::flags()], [qw(login password)], "exception contains the right flags");
}

{
    my $e = PermissionException->new('This is the text', qw(login password));
    is($e, '[PermissionException|login|password|]This is the text', "exception + flags looks good");
    is_deeply([$e->get::flags()], [qw(login password)], "exception contains the right flags");
}

{
    my $e = PermissionException->new('This is the text', qw(login));
    is($e, '[PermissionException|login|]This is the text', "exception + flags looks good");
    ok($e->has::login, "exception has login");
    ok(!$e->has::password, "exception doesn't have login");
    is_deeply([$e->get::flags()], [qw(login)], "exception contains the right flags");
}

{
    my $e = PermissionException2->new('This is the text');
    is($e, '[PermissionException2||]This is the text', "exception2 without flags looks good");
    is_deeply([$e->get::flags()], [], "exception contains no flags");
}

{
    like( exception { PermissionException2->new('This is the text', qw(login)) },
          qr/invalid flag 'login', exception type 'PermissionException2' didn't declare it/,
          "exception2 with invalid flag" );
}

{
    eval { PermissionException->throw('This is the text', qw(login password)) }
    or do { my $e = $@;
            ok($e->is::a('PermissionException'), "exception is of right type");
            is($e->get::type(), 'PermissionException', "exception type is ok");
        };
}

done_testing();
