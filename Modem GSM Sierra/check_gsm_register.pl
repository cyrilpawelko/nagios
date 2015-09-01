#!/usr/bin/perl
# check_gsm_register.pl
# Cyril - Pygram 24/03/2014
# Base sur http://www.inter-network.co.uk/?p=94
# Connects  modem on /dev/ttyUSB0
# Issues AT+CREG command to get registration status

use Device::Modem;
use Switch;

my $modem = new Device::Modem( port => '/dev/ttyUSB0' );

if( $modem->connect( baudrate => 115200 ) ) {
  } else {
      print "No connection with serial port!\n";
          $result = 3;
          exit $result;
  }

# Reset the modem, then send in the AT commands.
# Use the builtin carriage return function - or have a bad time.

$modem->atsend( 'AT+CREG?' . Device::Modem::CR );
$creg = $modem->answer();
#print "CREG=$creg\n";
# Some wrangling - its content over style I'm afraid

$creg =~ s/OK//g;

# Remove all newline chars to get sensible output.
$creg =~ s/\r\n//g;

$creg =~ s/^\+CREG\:\ //;
my($mode, $status) = split(/,/, $creg, 2);

# http://m2msupport.net/m2msupport/atcreg-network-registration/
if ( $status == 1 ) { print "Enregistrement operateur GSM OK (mode=$mode,status=$status)\n"; exit 0 }
else { print "Enregistrement operateur GSM non OK (mode=$mode,status=$status)\n"; exit 2 }
