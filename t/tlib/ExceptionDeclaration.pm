use strict;
use warnings;

use Exception::Stringy;
Exception::Stringy->declare_exceptions(
     'Some::Exception' => {
          fields => [ 'field1', 'field2' ],
          alias  => 'throw_exception',
     },
);
1;

