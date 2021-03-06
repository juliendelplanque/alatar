package Alatar::Model::SqlFunctionInvocation;

use strict;
use Alatar::Model::SqlObject;
use Alatar::Model::SqlFunctionInvocation;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name,$argumentsNumber) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{argumentsNumber} = $argumentsNumber;
	$this->{functionReference} = undef;
 	bless($this,$class);      
 	return $this;            
}

sub isSqlFunctionInvocation {
	my ($this) = @_;
	return 1;
}

# return true if the function invocation aims a stub
sub isStub {
	my ($this) = @_;
	return !defined($this->getFunctionReference())
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlFunctionInvocation';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name} . ' with ' . $this->getArgumentsNumber();
}

# Setters and getters
# ----------------------------------------------------
sub getArgumentsNumber {
	my ($this) = @_;
	return $this->{argumentsNumber};
}

sub setReturnType {
	my ($this,$returnType) = @_;
	$this->{returnType} = $returnType;
}

sub getFunctionReference {
	my ($this) = @_;
	return $this->{functionReference};
}

sub setFunctionReference {
	my ($this,$functionReference) = @_;
	$this->{functionReference} = $functionReference;
}

# Actions
# ----------------------------------------------------

# Return true if the function have the same signature that the other function
sub isInvocationOf {
	my ($this,$function) = @_;
	return (($this->getName() eq $function->getName()) && ($this->getArgumentsNumber() == $function->getArgumentsNumber()))
}

1;