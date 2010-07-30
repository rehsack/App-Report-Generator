#!perl

use strict;
use warnings;

use Test::More;
use App::Cmd::Tester;

use App::Report::Generator;
use Data::Dumper;

use Cwd;
use File::Basename ();
use File::Path;
use File::Spec ();
use YAML::Any qw(LoadFile DumpFile);

my $dir = File::Spec->catdir( getcwd(), 'test_output' );

rmtree $dir;
END { rmtree $dir }
mkpath $dir;
mkpath( File::Spec->catdir( $dir, 'etc' ) );

my $examples = File::Spec->catdir( getcwd(), 'examples' );

my $example_yamls = File::Spec->catfile( $examples, 'etc', '*.yml' );
foreach my $yml ( glob($example_yamls) )
{
    my $tgtfn = File::Spec->catfile( $dir, 'etc', File::Basename::basename($yml) );
    my $testyml = LoadFile($yml);
    $testyml->{"Report::Generator::Render::TT2"}->{output} =
      File::Spec->catfile( $dir, $testyml->{"Report::Generator::Render::TT2"}->{output} );
    $testyml->{"Report::Generator::Render::TT2"}->{template} =
      File::Spec->catfile( $examples, $testyml->{"Report::Generator::Render::TT2"}->{template} );
    DumpFile( $tgtfn, $testyml );
}

$ENV{APP_GENREPORT_CONFIGBASE} = 'test_output';
my $result = test_app( 'App::Report::Generator' => ['demo-report'] );

is( $result->stderr, '',    'nothing sent to sderr' );
is( $result->error,  undef, 'threw no exceptions' );

ok( -f File::Spec->catfile( $dir, "demo.sql" ), "generated file exists" );

done_testing();
