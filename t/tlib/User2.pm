package # hide from CPAN
User2;

use ExceptionDeclaration;
use Exception::Stringy;

sub test_user2 {
    throw_exception("user2", field2 => 1);
}

1;
