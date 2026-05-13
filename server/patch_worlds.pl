#!/usr/bin/perl
use strict;
use warnings;

my %VOIDGEN_WORLDS = (
    'hub'       => 'false',
    'OBSPAWN'   => 'false',
    'oneblock'  => 'true',
    'PIT'       => 'true',
    'voidworld' => 'true',
    'Bedwars'   => 'true',
);

my $yml = 'plugins/Multiverse-Core/worlds.yml';

unless (-f $yml) {
    print "[patch_worlds] worlds.yml not found, skipping.\n";
    exit 0;
}

open(my $fh, '<', $yml) or die "Cannot open $yml: $!";
my @lines = <$fh>;
close($fh);

my $current_world = '';
my @result;
my @changed;

for my $line (@lines) {
    if ($line =~ /^  ([A-Za-z_][A-Za-z0-9_]*):$/) {
        $current_world = $1;
    }

    if (exists $VOIDGEN_WORLDS{$current_world}
        && $line =~ /^(\s+)generator:\s+(.+)$/) {
        my $indent = $1;
        my $val = $2;
        $val =~ s/^['"]|['"]$//g;
        if ($val =~ /^VoidGen|^Voidgen/) {
            my $mobs = $VOIDGEN_WORLDS{$current_world};
            my $new_line = $indent . "generator: 'VoidGen:{\"mobs\":" . $mobs . "}'\n";
            if ($line ne $new_line) {
                push @changed, "  $current_world: mobs=$mobs";
            }
            $line = $new_line;
        }
    }

    push @result, $line;
}

open(my $out, '>', $yml) or die "Cannot write $yml: $!";
print $out @result;
close($out);

if (@changed) {
    print "[patch_worlds] Applied generator patches:\n";
    print "$_\n" for @changed;
} else {
    print "[patch_worlds] worlds.yml already up to date.\n";
}
