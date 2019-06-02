#!/usr/bin/env perl

# longorf-acetoscan.pl
# Based on longorf.pl v0208020920 (c) Dan Kortschak 2002
# Modifications by JN tor 25 apr 2019 14:41:40

use vars qw($USAGE);

use strict;
use Getopt::Long;
use Bio::SeqIO;
use Data::Dumper;

$USAGE = "longorf-acetoscan.pl [--help] seqfile\n";

my $sequencefile   = undef;
my $sequenceformat = 'fasta';
my $notstrict      = 1;
my $revcomp        = 1;
my $filter         = 1;
my $help           = undef;

GetOptions(
    'notstrict' => \$notstrict,
    'revcomp!'  => \$revcomp,
    'filter!'   => \$filter,
    'help|h'    => \$help,
);

if ($help) {
    exec( 'perldoc', $0 );
    die;
}

if ( !defined $sequencefile ) {
    $sequencefile = shift(@ARGV);
}

sub longestORF {
    my $best = 0;
    my ( $bests, $beste, $beststrand ) = ( -1, -1, 0 );
    my $bestorf = "";

    my $relaxed = $_[1]; # strict or not
    my $dna     = Bio::Seq->new( -seq => $_[0] );
    my %strand  = (
        '+' => $dna->seq,
        '-' => $dna->revcom->seq
    );

    foreach my $direction ( keys %strand ) {
        my @starts = ();
        my @ends   = ();
        if ($relaxed) {
            for ( my $frame = 0 ; $frame < 3 ; $frame++ ) {
                unless ( $strand{$direction} =~ m/^.{$frame}(taa|tga|tag)/i ) {
                    push @starts, $frame + 1;
                }
            }
        }

        while ( $strand{$direction} =~ m/(atg)/gi ) {
            push @starts, pos( $strand{$direction} ) - 2;
        }

        while ( $strand{$direction} =~ m/(taa|tga|tag)/gi ) {
            push @ends, pos( $strand{$direction} ) - 2;
        }

        push @ends, ( $dna->length - 2, $dna->length - 1, $dna->length );

        for my $s (@starts) {
            for my $e (@ends) {
                if ( $e % 3 == $s % 3 and $e > $s ) {
                    if ( $e - $s > $best ) {
                        $best = $e - $s;
                        ( $bests, $beste, $beststrand ) = ( $s, $e, $direction );
                        $bestorf = Bio::Seq->new(-seq => $strand{$direction})->subseq($s,$e);
                        if ($revcomp) {
                            if ($direction eq '-') {
                                my $testorf = Bio::Seq->new(-seq => $bestorf)->revcom;
                                $bestorf = $testorf->seq;
                            }
                        }
                    }
                    last;
                }
                else {
                    next;
                }
            }
        }
    }
    return ( $best, $bests, $beste, $beststrand, $bestorf );
}

my $seqio = new Bio::SeqIO(
    '-format' => $sequenceformat,
    '-file'   => $sequencefile
);

my ( $length, $start, $end, $direction, $sequence );

while ( my $dna = $seqio->next_seq ) {
    ($length, $start, $end, $direction, $sequence) = longestORF($dna->seq, $notstrict);
    my $header = $dna->display_id ." $length:$start:$end ($direction)";
    if ($filter) {
        $header =~ s/:|\s+|\(|\)/_/g;
        $header =~ s/__\+_$/_plus/;
        $header =~ s/__\-_$/_minus/;
    }
    print STDOUT ">", $header, "\n";
    print STDOUT "$sequence\n";
}


__END__

=head1 NAME

longorf-acetoscan.pl - perl script to find the longest ORF of a sequence

=head1 SYNOPSIS

% longorf-acetoscan.pl [-h] seqfile

=head1 DESCRIPTION

This script will examine a set of nucleotide sequences in fasta format
and determine the longest ORF in each sequence. ORFs may start at the
canonical ATG or at the beginning of the sequence.

The ORF is printed to STDOUT, with some info on length and strand.

ORFS matching minus strand are reverse-complemented in output. To
prevent this, use '--norevcomp' as option.

If fasta headers needs to be filtered against "offending characters"
(spaces, semi colon, etc), then use the "--filter" option, which will
try to replace these with underscores.

=head1 AUTHOR

Johan Nylander, NBIS/NRM

=cut
