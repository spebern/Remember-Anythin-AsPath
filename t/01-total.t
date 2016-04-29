use strict;
use warnings;
use Test::More;
use File::Path qw(remove_tree);

if (eval{ require Digest::SHA }) {
    Digest::SHA->import('sha256_hex');
    plan tests => 7;
}
else {
    plan skip_all => "Need 'Digest::SHA' available for testing";
}

use_ok('Remember::Anything::AsPath');

(my $cur_dir = __FILE__) =~ s/01-total.t$//;

my $some_obj = bless {
    foo  => 'bar',
    aref => [0 .. 10],
    href => {
        foo => 'bar',
    },
    obj  => (bless { foo => 'bar' }, 'AnotherClass'),
    sref => sub { 'hello world' },
}, 'SomeClass';

{ # default attrib
    my $db_brain = Remember::Anything::AsPath->new(
        out_dir => $cur_dir,
    );

    is $db_brain->seen($some_obj), 0, 'Unknown object is not found (1)';

    $db_brain->remember($some_obj);
    is $db_brain->seen($some_obj), 1, 'Remembered object (1)';

    my $id_file = "${cur_dir}cc028d1da2288e/a84dd7a3fc1b0d/b7fee7844554";
    ok -e $id_file, 'Default treedepth and file id correct';
    remove_tree("${cur_dir}cc028d1da2288e");
}

{ # custom threedepth, and digest sub
    $cur_dir =~ s{\/$}{};
    my $digest_sub = \&sha256_hex;
    my $db_brain = Remember::Anything::AsPath->new(
        out_dir    => $cur_dir,
        digest_sub => $digest_sub,
        tree_depth => 4,
    );

    is $db_brain->seen($some_obj), 0, 'Unknown object is not found (2)';
    $db_brain->remember($some_obj);

    is $db_brain->seen($some_obj), 1, 'Remembered object (2)';

    my $id_file = "$cur_dir/ff85dc15d5cbd20e2/6a835927b7203323a/9943f2da65cb33e4b/dcb1654822506";
    ok -e $id_file, 'Custom treedepth and file id correct';
    remove_tree("$cur_dir/ff85dc15d5cbd20e2");
}

