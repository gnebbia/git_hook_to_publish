#!/usr/bin/env perl
#
# Short description for git_hook_to_publish.pl
#
# Author giuseppe <giuseppe@linux-029m>
# Version 0.1
# Copyright (C) 2018 giuseppe <giuseppe@linux-029m>
# Modified On 2018-08-03 12:10
# Created  2018-08-03 12:10
#
use strict;
use warnings;
use Modern::Perl;
use DateTime;
use File::Path qw(make_path);
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);


my $filename = "README.md";
my @lines;
my $title;
my $title_catched = 0;
if (open(my $fh, '<:encoding(UTF-8)', $filename)) {
    while (my $row = <$fh>) {
        if ($row =~ /^# (.*)/ && not $title_catched){
            $title_catched = 1;
            $title = $1;
        } else {
            if ( $row =~ /\(img\//){
                $title =~ s/ /_/g;
                $title = lc $title;
                $row =~ s/img/\/${title}_img/;
                push @lines, $row;
            } else {
                push @lines, $row;
            }
        }
    }
} else {
    warn "Could not open file '$filename' $!";
}


my $dt = DateTime->now;
my $date = $dt->ymd;
my $time = $dt->hms;

my $article_header = <<"EOH";
<!--
.. title: $title 
.. slug: index
.. date: $date $time UTC+02:00
.. tags: 
.. category: 
.. link: 
.. description: 
.. type: text
-->
EOH

unshift @lines, $article_header;

$title =~ s/ /_/g;
$title = lc $title;

my $dir = "$ENV{'HOME'}/nikola/nebbia/pages/material/$title/";
eval { make_path($dir) };
if ($@) {
    print "Couldn't create $dir: $@";
}


my $path_to_website = $dir."index.md";

open(my $f_out, '>', $path_to_website) or die "Could not open file '$path_to_website' $!";
print $f_out @lines;

my $current_img_dir = "img/";
my $new_img_dir = "$ENV{'HOME'}/nikola/nebbia/files/${title}_img/";

dircopy($current_img_dir,$new_img_dir);


