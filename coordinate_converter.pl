use strict;
use warnings;
use Bio::EnsEMBL::Registry;

if ($#ARGV != 2 ) {
	print "usage: coordinate_converter.pl chromosome_number start end\neg: coordinate_converter.pl 10 25000 30000\n";
	exit;
}

my ($cno, $first, $last) = @ARGV;

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
    -user => 'anonymous'
);

my $slice_adaptor = $registry->get_adaptor( 'human', 'Core', 'Slice' );

my $slice = $slice_adaptor->fetch_by_region('chromosome', "$cno", "$first", "$last", '1', 'GRCh38');

# Print the coordinates on the current assembly	i.e., GRCh38
printf( "Slice on chromosome %s at %d-%d in GRCh38 projects to the following on GRCh37 :\n",
    $slice->seq_region_name(), $slice->start(), $slice->end()
);

# Convert to coordinates on GRCh37
my $projection = $slice->project('chromosome','GRCh37');

# Print the converted coordinates on GRCh37
foreach my $segment ( @{$projection} ) {
    my $to_slice = $segment->to_Slice();

    printf(
        "%d-%d\n",
		$to_slice->start(), $to_slice->end()
    );
}
