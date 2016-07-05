package PgExtractor;

use strict;
use Attribute::Abstract;

use Data::Dumper;
sub new {
	my ($class,$owner,$code) = @_;
	my $this = { 
		owner => $owner,
		entity => undef
	};
=begin
	foreach my $var (@properties) {
		$this->{$var} = undef;
	}
=cut
 	bless($this,$class); 
 	if(defined($code)) {
	 	$this->_extractObject($code);
 	}
 	return $this;            
}

# setters and getters
# --------------------------------------------------

sub getEntity {
	my($this) = @_;
	return $this->{entity};
}

# actions
# --------------------------------------------------
sub _extractObject: Abstract;

1;