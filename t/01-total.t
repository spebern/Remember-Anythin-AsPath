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
}, 'SomeClass';

{ # default attrib
    my $db_brain = Remember::Anything::AsPath->new(
        out_dir => $cur_dir,
    );

    is $db_brain->seen($some_obj), 0, 'Unknown object is not found (1)';

    $db_brain->remember($some_obj);
    is $db_brain->seen($some_obj), 1, 'Remembered object (1)';

    my $id_file = "${cur_dir}240332dfa0af11/ada007089ff78b/4dc00fa6db94";
    ok -e $id_file, 'Default treedepth and file id correct';
    remove_tree("${cur_dir}240332dfa0af11");
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

    my $id_file = "$cur_dir/92997b4fef5ffd18d/0ee0d3bcfd8f3f7c0/3d224cb6612c33f7b/22b5129616034";
    ok -e $id_file, 'Custom treedepth and file id correct';
    remove_tree("$cur_dir/92997b4fef5ffd18d");
}
