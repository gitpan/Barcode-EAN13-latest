use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Barcode::EAN13',
    'VERSION_FROM' => 'EAN13.pm', # finds $VERSION
);
