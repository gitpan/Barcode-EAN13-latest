# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

use strict;

use vars qw($Total_tests);

my $loaded;
my $test_num = 0;
my $OK_tests = 0;

BEGIN { $| = 1; $^W = 1; $test_num=1}
END {print "not ok $test_num\n" unless $loaded;}
print "1..$Total_tests\n";
use Barcode::EAN13 qw/:all/;
$loaded = 1;
ok(1, 'compile()' );

# Utility testing functions.
sub ok {
    my ($test, $name) = @_;
    if ($test) {
      $OK_tests++;
    } else {
      print "not ";
    }
    printf "ok %d", ++$test_num;
    print " - $name" if defined $name;
    print "\n";
}

######################### End of black magic.

BEGIN { $Total_tests = 18 }

# Valid barcode is OK
ok(valid_barcode("5023965006028"), "ok valid"); 

# Invalid barcode fails
ok(!valid_barcode("5023965006027"), "failed valid");

# Correctly calculates check digit
ok((check_digit("502396500602") == 8), "checkdigit ok");

# Correctly calculates check digit ending in zero
ok((check_digit("503069708024") == 0), "zero checkdigit ok");

# Returns undef with invalid checkdigit
{
  # We don't actually want to print the warning
  local $^W = 0;
  ok(!defined(check_digit("50239650060")), "invalid stem for check digit");
}

# Picks correct barcode from a list
{
  my @barcodes = qw/5391500385083 5014138036041/;
  ok((best_barcode(\@barcodes, [50, 539]) eq "5014138036041"), "best barcode UK vs IE");
}

# Picks correct barcode from a list
{
  my @barcodes = qw/5391500385083 5014138036041/;
  ok((best_barcode(\@barcodes, [539, 50]) eq "5391500385083"), "best barcode IE vs UK");
}

# Picks correct barcode from a list
{
  my @barcodes = qw/5391500385083 5014138036041/;
  ok((best_barcode(\@barcodes, ["uk", "ie"]) eq "5014138036041"), "best barcode UK vs IE named");
}

# Picks correct barcode from a list
{
  my @barcodes = qw/5391500385083 5014138036041/;
  ok((best_barcode(\@barcodes, ["ie", "uk"]) eq "5391500385083"), "best barcode IE vs UK named");
}

# Fails to pick a best barcode cos none are valid (no prefs)
{
  my @barcodes = qw/5023965006027 602396500602 50239650060289/;
  ok(!defined(best_barcode(\@barcodes)), "no best barcode, no prefs");
}

# Fails to pick a best barcode cos none are valid (UK prefs)
{
  my @barcodes = qw/5023965006027 602396500602 50239650060289/;
  my @prefs = qw/50/;
  ok(!defined(best_barcode(\@barcodes, \@prefs)), "no best barcode, prefs");
}

# Fails to pick a best barcode cos none are valid (named prefs)
{
  my @barcodes = qw/5023965006027 602396500602 50239650060289/;
  my @prefs = qw/uk ie/;
  ok(!defined(best_barcode(\@barcodes, \@prefs)), "no best barcode, named prefs");
}

# Picks correct barcode from a list, with no preferences
# and only one valid barcode
{
  my @barcodes = qw/5023965006028 5023965006027 502396500602 50239650060289/;
  ok((best_barcode(\@barcodes) eq "5023965006028"), "best barcode, no prefs");
}

# Picks correct barcode from a list, with UK preference, but
# only one valid barcode
{
  my @prefs = qw/50/;
  my @barcodes = qw/5023965006028 5023965006027 502396500602 50239650060289/;
  ok((best_barcode(\@barcodes, \@prefs) eq "5023965006028"), "best barcode, top pref");
}

# Picks correct barcode from a list, with non-existing preference, but
# only one valid barcode
{
  my @prefs = qw/70/;
  my @barcodes = qw/5023965006026 5023965006028 5023965006027 502396500602 50239650060289/;
  ok((best_barcode(\@barcodes, \@prefs) eq "5023965006028"), "best barcode, none in prefs");
}

# Add some tests for fall through to invalids ...

# Test issuing country
# only one valid barcode
ok((issuer_ccode("5023965006028") eq "uk"), "issuing country: uk");
ok((issuer_ccode("9999999999999") eq ""), "issuing country: n/a");

warn "You actually had $test_num tests ...\n" unless ($test_num == $Total_tests);
# die "Only $OK_tests out of $Total_tests OK...\n" unless ($OK_tests == $Total_tests);

