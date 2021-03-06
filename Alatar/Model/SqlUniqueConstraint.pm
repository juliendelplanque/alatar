package Alatar::Model::SqlUniqueConstraint;

use strict;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlConstraint);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
 	bless($this,$class);
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlUniqueConstraint';
}

sub isSqlUniqueConstraint {
	my ($this) = @_;
	return 1;
}

1;