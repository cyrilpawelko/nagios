#!/usr/bin/perl
# check_gsm_signal.pl
# Cyril - Pygram 24/03/2014
# Base sur http://www.inter-network.co.uk/?p=94
# Connects  modem on /dev/ttyUSB0
# Issues AT+CSQ command to get RSSI and BER
# Returns state with perdata
 
use Device::Modem;
use Switch;
 
my $modem = new Device::Modem( port => '/dev/ttyUSB0' );

my $quality = "";
my $result = 3;
my $db = 0;
my $message = "";

if( $modem->connect( baudrate => 115200 ) ) {
  } else {
      print "No connection with serial port!\n";
	  $result = 3;
	  exit $result;
  }
 
# Reset the modem, then send in the AT commands.
# Use the builtin carriage return function - or have a bad time.
 
$modem->atsend( 'AT+CSQ' . Device::Modem::CR );
$csq = $modem->answer();
 
# Some wrangling - its content over style I'm afraid
 
$csq =~ s/OK//g;
 
# Remove all newline chars to get sensible output.
$csq =~ s/\r\n//g;
 
$csq =~ s/^\+CSQ\:\ //;
my($sig, $ber) = split(/,/, $csq, 2);
 
# conversion signal 
# http://acassis.wordpress.com/2009/12/21/converting-csq-to-dbm/ et 
# http://m2msupport.net/m2msupport/atcsq-signal-quality/

if ($sig == 99) {
	$result = 3;
	$db = 0;
	$message = "signal inconnu ou non detectable";
}
else {
	$db = -113 + ($sig * 2);
	switch ($sig) {
		case [1..9] { $result = 2; $message = "signal faible" }
		case [10..14] { $result = 0; $message = "signal correct" }
		case [15..19] { $result = 0; $message = "signal bon" }
		case [20..30] { $result = 0; $message = "signal excellent" }
	}
}
print "Modem GSM $message ($db dB)|rssi=$db, ber=$ber\n";
exit $result