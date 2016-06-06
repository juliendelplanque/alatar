package SqlDatabase;

use SqlResolver;
use Data::Dumper;
use strict;
use SqlFunction;
use SqlTrigger; 

sub new {
	my ($class,$name,$schema) = @_;
	my $this = {
		name => $name,
		schema => $schema,
		objects => [ ],
		resolver => undef
	};
 	bless($this,$class); 
 	$this->{resolver} = SqlResolver->new($this);
 	$this->extractFunctions();
 	$this->extractTriggers();
 	$this->{resolver}->resolveAllLinks();
 	return $this;            
}

sub getName {
	my ($this) = @_;
	return $this->{name};
}

sub getSchema {
	my ($this) = @_;
	return $this->{schema};
}

sub addObject {
	my ($this,$sqlObject) = @_;
	push(@{$this->{objects}},$sqlObject);
}

sub getObjects {
	my ($this) = @_;
	return @{$this->{objects}};
}

sub extractFunctions {
	my ($this) = @_;
	my @functions = $this->{schema} =~ /CREATE FUNCTION\s(.*?)END;\$\$;/g;
	foreach my $fcode (@functions) {
		$this->addObject(SqlFunction->new($this,$fcode));
	}
}

sub extractTriggers {
	my ($this) = @_;
	my @triggers = $this->{schema} =~ /CREATE TRIGGER\s(.*?);/g;
	foreach my $trigger (@triggers) {
		$this->addObject(SqlTrigger->new($this,$trigger));
	}
}

sub getSqlFunctions {
	my ($this) = @_;
	my @functions;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlFunction()) {
	 		push(@functions,$obj);
	 	}
	}
	return @functions;
}

sub getSqlTriggers {
	my ($this) = @_;
	my @triggers;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlTrigger()) {
	 		push(@triggers,$obj);
	 	}
	}
	return @triggers;
}

sub getAllRequests {
	my ($this) = @_;
	my @requests;
	foreach my $f ($this->getSqlFunctions()) {
		foreach my $r ($f->getAllRequests()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

sub getSqlRequests {
	my ($this) = @_;
	my @requests;
	foreach my $f ($this->getSqlFunctions()) {
		foreach my $r ($f->getSqlRequests()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

sub getSqlCursorRequests {
	my ($this) = @_;
	my @requests;
	foreach my $f ($this->getSqlFunctions()) {
		foreach my $r ($f->getSqlCursorRequests()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

1;