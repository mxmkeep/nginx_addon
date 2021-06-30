#!/usr/bin/perl -w

# (c) Andrei Nigmatulin, 2005
#
# this script provided "as is", without any warranties. use it at your own risk.
#
# special thanx to Andrew Sitnikov for perl port
#
# this script converts CSV geoip database (free download at http://www.maxmind.com/app/geoip_country)
# to format, suitable for use with nginx_http_geo module (http://sysoev.ru/nginx)
#
# for example, line with ip range
#
#   "62.16.68.0","62.16.127.255","1041253376","1041268735","RU","Russian Federation"
#
# will be converted to four subnetworks:
#
#   62.16.68.0/22 RU;
#   62.16.72.0/21 RU;
#   62.16.80.0/20 RU;
#   62.16.96.0/19 RU;
#
# modify out put format - 2021-6-30
#17.81.15.0 17.81.15.255 17.81.15.0/24 255 CN; 
#17.81.16.0 17.81.23.255 17.81.16.0/21 2047 CN;
#17.81.24.0 17.81.25.255 17.81.24.0/23 511 CN; 
#17.81.27.0 17.81.27.255 17.81.27.0/24 255 CN; 
#17.81.28.0 17.81.31.255 17.81.28.0/22 1023 CN;
#17.81.32.0 17.81.35.255 17.81.32.0/22 1023 CN;                  

use warnings;
use strict;

while( <STDIN> ){
	if (/"[^"]+","[^"]+","([^"]+)","([^"]+)","([^"]+)"/){
		print_subnets($1, $2, $3);
	}
}

sub  print_subnets {
	my ($a1, $a2, $c) = @_;
	my $l;
	my $mask;
	my $ipmax;
    while ($a1 <= $a2) {
		for ($l = 0; ($a1 & (1 << $l)) == 0 && ($a1 + ((1 << ($l + 1)) - 1)) <= $a2; $l++){};
		$mask = 32 - $l;
		$ipmax = ($a1 & ~( (0x1 << (32 - $mask)) - 1)) + ( (0x1 << (32 - $mask)) - 1);
		print long2ip($a1) . " " . long2ip($ipmax)  . " " . long2ip($a1) . "/" . ($mask) . " " . ($ipmax-$a1) . " " . $c . ";\n";
    	$a1 += (1 << $l);
	}
}

sub long2ip {
	my $ip = shift;

	my $str = 0;

	$str = ($ip & 255);

	$ip >>= 8;
	$str = ($ip & 255).".$str";

	$ip >>= 8;
	$str = ($ip & 255).".$str";

	$ip >>= 8;
	$str = ($ip & 255).".$str";
}
