#!/usr/bin/perl
# $Id: ant.pl 129 2008-10-28 01:37:36Z luc.hermitte $ 
# Author:	Luc Hermitte <EMAIL:hermitte at free.fr>
#		<URL:http://hermitte.free.fr/vim>
# Purpose:	Get rid of ant format
# Created:	Mon 22 May 2006 08:12:59 PM CEST
# Last Update:  $date$
# ======================================================================

# Main loop: get rid of /^\s*[.*]\s*/
while (<>) 
{
    chop;
    $_ =~ s/^\s*\[.*?\]\s*// ;
    print "$_\n";
}
