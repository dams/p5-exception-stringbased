package # hide from CPAN
User1;

use ExceptionDeclaration;
use Exception::Stringy;

sub test_user1 {
    throw_exception("user1", field1 => 1);
}

1;
