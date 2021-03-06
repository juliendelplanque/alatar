package Alatar::Model::SqlColumnReference;

use strict;
use Alatar::Model::SqlReference;
use Data::Dumper;

our @ISA = qw(Alatar::Model::SqlReference);

sub new {
	my ($class,$owner,$name,$table,$column) = @_;
	my $this = $class->SUPER::new($owner,$name);
   	$this->{table} = $table;
   	$this->{column} = $column;
 	bless($this,$class);      
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlColumnReference';
}

sub isSqlColumnReference {
	my ($this) = @_;
	return 1;
}

# setter and getter
sub setTable {
	my ($this,$table) = @_;
	$this->{table} = $table;
}

sub getTable {
	my ($this) = @_;
	return $this->{table};
}

sub setColumn {
	my ($this,$column) = @_;
	$this->{column} = $column;
}

sub getColumn {
	my ($this) = @_;
	return $this->{column};
}


1;