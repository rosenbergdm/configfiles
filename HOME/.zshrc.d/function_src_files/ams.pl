#!/usr/bin/perl

# Generated by /usr/local/bin/sh2p.pl on Tue May  4 19:00:26 2010

use warnings;
use strict;
use integer;

# add_missing_svn.zsh

sub add_missing_svn() {
    system ("svn status | grep \? | awk -F \"       \" \"{print \\\"\\\\\"\\\" \$2 \\\"\\\\\"\\\"}\" | xargs svn add"); 
    system ("svn ci -m 'Added missing files'"); 

}

