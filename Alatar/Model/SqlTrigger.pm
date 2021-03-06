package Alatar::Model::SqlTrigger;

use strict;
use Data::Dumper;
use Regexp::Common;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlObject);

# il faut gérer les appels de fonctions avec arguments
# On ne conserve que le nom de la table, il faudrait une référence vers la table

sub new {
	my ($class,$owner) = @_;
 	my $this = $class->SUPER::new($owner,'undef');
 	$this->{_request} = '';
	$this->{fire} = '';
	$this->{events} = [ ];
	$this->{tableName} = '';
	$this->{tableReference} = undef;
	$this->{level} = '';
	$this->{invokedFunction} = undef;
	bless($this,$class);    
 	return $this;            
}

sub isSqlTrigger {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlTrigger';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType();
}

# setters and getters
# ----------------------------------------------------
sub getSqlRequest {
	my ($this) = @_;
	return $this->{_request};
}

sub setSqlRequest {
	my ($this,$request) = @_;
	$this->{_request} = $request;
}

sub getFire {
	my ($this) = @_;
	return $this->{fire};
}

sub setFire {
	my ($this,$value) = @_;
	$this->{fire} = $value;	
}

sub getEvents {
	my ($this) = @_;
	return @{$this->{events}};
}

sub addEvent {
	my ($this,$event) = @_;
	push(@{$this->{events}},$event);	
}

sub getTableName {
	my ($this) = @_;
	return $this->{tableName};
}

sub setTableName {
	my ($this,$value) = @_;
	$this->{tableName} = $value;	
}

sub getLevel {
	my ($this) = @_;
	return $this->{level};
}

sub setLevel {
	my ($this,$value) = @_;
	$this->{level} = $value;	
}

sub getTableReference {
	my ($this) = @_;
	return $this->{tableReference};
}

sub setTableReference {
	my ($this,$tableRef) = @_;
	$this->{tableReference} = $tableRef;	
}

sub getInvokedFunction {
	my ($this) = @_;
	return $this->{invokedFunction};
}

sub setInvokedFunction {
	my ($this,$value) = @_;
	$this->{invokedFunction} = $value;	
}

