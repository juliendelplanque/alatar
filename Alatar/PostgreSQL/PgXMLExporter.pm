package Alatar::PostgreSQL::PgXMLExporter;

# Produce serialized version of the object representation (XML)

use strict;
use XML::Writer;
use IO::File;
use Alatar::Configuration;

sub new {
	my ($class,$model) = @_;
	my $this = {
		model => $model
	};
	$this->{parseFilePath} = '"' . Alatar::Configuration->getOption('appFolder') . '/postgresql/parse_file' . '"';
	$this->{xmlOutput} = new IO::File(">" . Alatar::Configuration->getOption('xmlFilePath'));
	$this->{xmlWriter} = new XML::Writer(OUTPUT => $this->{xmlOutput}, DATA_MODE => 1, DATA_INDENT=>2);
 	bless($this,$class);
 	$this->{xmlWriter}->doctype('database');
	$this->{xmlWriter}->startTag('database',
		'clientEncoding' => $this->{model}->getClientEncoding()
	);
	$this->_addExtensions();
	$this->_addFunctions();
	$this->_addTables();
	$this->_addViews();
	$this->_addTriggerDefinitions();
	$this->_addSequences();
	$this->{xmlWriter}->endTag();	# end of schema definition
	$this->{xmlWriter}->end();
 	return $this;            
}

sub _exportSqlFileToJSOn {
	my ($this,$sqlPath) = @_;
	
	if(Alatar::Configuration->getOption('requestsPath')) {
		$this->{xmlWriter}->startTag('json');
		my $jsonData = qx { $this->{parseFilePath} "$sqlPath"};
		$this->{xmlWriter}->cdata($jsonData);
		$this->{xmlWriter}->endTag();
	}
}

# --------------------------------------------------
# Extensions
# --------------------------------------------------
sub _addExtensions {
	my ($this) = @_;
	
	$this->{xmlWriter}->startTag('extensions');
 	foreach my $e ($this->{model}->getExtensions()) {
	 	$this->{xmlWriter}->startTag('extension', 
	 			'name' => $e->getName(),
	 			'schema' => $e->getSchema()
	 		);
	 	$this->{xmlWriter}->startTag('comment');
		$this->{xmlWriter}->cdata($e->getComment());
		$this->{xmlWriter}->endTag();
	 	$this->{xmlWriter}->endTag();
 	}
 	$this->{xmlWriter}->endTag();	# end of extensions list
}

# --------------------------------------------------
# Functions
# --------------------------------------------------	
sub _addFunctions {
	my ($this) = @_;
	my (@args,@requests,@cursors,@invokedMethods,@callers,@row);
	
 	$this->{xmlWriter}->startTag('functions');
 	foreach my $f ($this->{model}->getSqlFunctions()) { 
 		$this->{xmlWriter}->startTag('function', 
 			'name' => $f->getName(),
 			'id' => $f->getId(),
 			'language' => $f->getLanguage(),
 			'returnType' => $f->getReturnTypeName(),
 			'comments' => ($f->isCommented() ? 'true' : 'false')
 		);
 		@args = $f->getArgs();
 		if(@args) {
	 		$this->{xmlWriter}->startTag('arguments');
	 		foreach my $a (@args) {
	 			$this->{xmlWriter}->startTag('argument',
	 				'id' => $a->getId()
	 			);
	 			$this->{xmlWriter}->startTag('name');
	 			$this->{xmlWriter}->characters($a->getName());
	 			$this->{xmlWriter}->endTag();
	 			$this->{xmlWriter}->startTag('type');
	 			$this->{xmlWriter}->characters($a->getDataType()->getName());
	 			$this->{xmlWriter}->endTag();
	 			$this->{xmlWriter}->endTag();
	 		}
	 		$this->{xmlWriter}->endTag();
 		}
 		if($f->getAllRequests()) {
 			@requests = $f->getSqlRequests();
 			if(@requests) {
		 		$this->{xmlWriter}->startTag('requests');
		 		foreach my $r (@requests) {
					$this->{xmlWriter}->startTag('request',
						'name' => $r->getName(),
						 'id' => $r->getId()
					);
					$this->{xmlWriter}->startTag('sql');
					$this->{xmlWriter}->cdata($r->getRequest());
		 			$this->{xmlWriter}->endTag();
		 			
		 			$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('requests_folder') . '/' . $r->getName() . '.sql');

		 			$this->{xmlWriter}->endTag();
		 		}
		 		$this->{xmlWriter}->endTag();
 			}
 			@cursors = $f->getSqlCursorRequests();
 			
			if(@cursors) {
				$this->{xmlWriter}->startTag('cursors');
		 		foreach my $r (@cursors) {
					$this->{xmlWriter}->startTag('cursor',
						'name' => $r->getName(),
						'id' => $r->getId()
					);
					@args = $r->getArgs();
					if(@args) {
						$this->{xmlWriter}->startTag('arguments');
						foreach $a (@args) {
							$this->{xmlWriter}->startTag('argument');
				 			$this->{xmlWriter}->startTag('name');
				 			$this->{xmlWriter}->characters($a->getName());
				 			$this->{xmlWriter}->endTag();
				 			$this->{xmlWriter}->startTag('type');
				 			$this->{xmlWriter}->characters($a->getDataType()->getName());
				 			$this->{xmlWriter}->endTag();
				 			$this->{xmlWriter}->endTag();
						}
						$this->{xmlWriter}->endTag();
					}
					$this->{xmlWriter}->startTag('sql');
					$this->{xmlWriter}->cdata($r->getRequest());
		 			$this->{xmlWriter}->endTag();
		 			
		 			$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('cursors_folder') . '/' . $r->{owner}->getName() . '_' . $r->getName() . '.sql');
		 				
		 			$this->{xmlWriter}->endTag();
		 		}
		 		$this->{xmlWriter}->endTag();
			}
		}
		@invokedMethods = $f->getInvokedFunctions();
		if(@invokedMethods) {
	 		$this->{xmlWriter}->startTag('invokedFunctions');
	 		foreach my $if (@invokedMethods) {
	 			if(!$if->isStub()) { # Temporary solution. We must produce stub functions in the model to avoid broken references
		 			$this->{xmlWriter}->startTag('invokedFunction',
		 				'argumentsNumber' => $if->getArgumentsNumber(),
		 				'stub' => ($if->isStub() ? 'true' : 'false'),
		 				'id' => $if->getFunctionReference()->getId()
		 			);
	 			} else {
	 				$this->{xmlWriter}->startTag('invokedFunction',
		 				'argumentsNumber' => $if->getArgumentsNumber(),
		 				'stub' => 'true'
		 			);
	 			}
	 			$this->{xmlWriter}->characters($if->getName());
	 			$this->{xmlWriter}->endTag();
	 		}
	 		$this->{xmlWriter}->endTag();
		}
		@callers = $f->getCallers();
		if(@callers) {
			$this->{xmlWriter}->startTag('callers');
	 		foreach my $caller (@callers) {
	 			$this->{xmlWriter}->startTag('caller',
	 				'argumentsNumber' => $caller->getArgumentsNumber(),
	 				'stub' => ($caller->isStub() ? 'true' : 'false'),
	 				'id' => $caller->getFunctionReference()->getId()
	 			);
	 			$this->{xmlWriter}->characters($caller->getName());
	 			$this->{xmlWriter}->endTag();
	 		}
	 		$this->{xmlWriter}->endTag();
		}

 		if($f->isTriggerFunction()) {
 			@row = $f->getNewColumns();
 			if(@row) {
 				$this->{xmlWriter}->startTag('newRow');
 				foreach my $c (@row) {
 					$this->{xmlWriter}->startTag('new');
 					$this->{xmlWriter}->characters($c);
 					$this->{xmlWriter}->endTag();
 				}
 				$this->{xmlWriter}->endTag();
 			}
 			@row = $f->getOldColumns();
 			if(@row) {
 				$this->{xmlWriter}->startTag('oldRow');
 				foreach my $c (@row) {
 					$this->{xmlWriter}->startTag('old');
 					$this->{xmlWriter}->characters($c);
 					$this->{xmlWriter}->endTag();
 				}
 				$this->{xmlWriter}->endTag();
 			}
 		}
 		$this->{xmlWriter}->endTag();
 	}
 	$this->{xmlWriter}->endTag();	# end of function definition
}

# --------------------------------------------------
# Export the rules in tables and views
# --------------------------------------------------
sub _exportRulesOf {
	my ($this,$table) = @_;
	my @rules;
	foreach my $rule ($this->{model}->getSqlRules()) {
		if($rule->getTable()->getTableName() eq $table->getName()) {
			push(@rules,$rule);
		}
	}
	if(@rules) {
		$this->{xmlWriter}->startTag('rules');
		foreach my $r (@rules) {
			$this->{xmlWriter}->startTag('rule',
				'name' => $r->getName(),
				'id' => $r->getId(),
				'event' => $r->getEvent(),
				'mode' => ($r->doInstead() ? 'INSTEAD' : 'ALSO')
			);
			$this->{xmlWriter}->startTag('request',
				'name' => ($r->getSqlRequest()->getName()),
				'id' => $r->getId()
			);
			$this->{xmlWriter}->startTag('sql');
			$this->{xmlWriter}->cdata($r->getSqlRequest()->getRequest());
			$this->{xmlWriter}->endTag(); # end of sql definition
			
			$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('rules_folder') . '/' . $r->getName() . '_' . $r->getId() . '.sql');
			
			$this->{xmlWriter}->endTag(); # end of request definition
			$this->{xmlWriter}->endTag(); # end of rule tag
		}
		$this->{xmlWriter}->endTag();	# end of rules definition
	}
}

# --------------------------------------------------
# Table definitions
# --------------------------------------------------
sub _addTables {
	my ($this) = @_;
	$this->{xmlWriter}->startTag('tables');
	foreach my $t ($this->{model}->getSqlTables()) {
		$this->{xmlWriter}->startTag('table',
			'name' => $t->getName(),
			'id' => $t->getId()
		);
		if($t->isChild()) {
			$this->{xmlWriter}->startTag('parentTables');
			foreach my $parentTable ($t->getParentTables()) {
				$this->{xmlWriter}->startTag('parentTable',
					'name' => $parentTable->getTableName(),
					'id' => $parentTable->getId()
				);
				$this->{xmlWriter}->endTag(); # end of tag parentTable
			}
			$this->{xmlWriter}->endTag(); # end of tag parentTables
		}
		$this->{xmlWriter}->startTag('columns');
		foreach my $c ($t->getColumns()) {
			$this->{xmlWriter}->startTag('column',
				'name' => $c->getName(),
				'id' => $c->getId(),
				'type' => $c->getDataType()->getName(),
				'notNull' => ($c->isNotNull() ? 'true' : 'false'),
				'primaryKey' => ($c->isPk() ? 'true' : 'false'),
				'foreignKey' => ($c->isFk() ? 'true' : 'false'),
				'inherited' => ($c->isInherited() ? 'true' : 'false')
			);
			$this->{xmlWriter}->endTag(); # end of column tag
		}
		$this->{xmlWriter}->endTag(); # end of columns tag

		$this->{xmlWriter}->startTag('sql');
		$this->{xmlWriter}->cdata($t->getSqlRequest()->getRequest());
		$this->{xmlWriter}->endTag(); # end of sql definition
		
		$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('tables_folder') . '/' . $t->getName() . '.sql');
		
		# the rules are exported
		$this->_exportRulesOf($t);
	
		$this->{xmlWriter}->endTag(); # end of table tag
	}
	$this->{xmlWriter}->endTag();	# end of table definition
}

# --------------------------------------------------
# Views definitions
# --------------------------------------------------
sub _addViews {
	my ($this) = @_;
	$this->{xmlWriter}->startTag('views');
	foreach my $v ($this->{model}->getSqlViews()) {
		$this->{xmlWriter}->startTag('view',
			'name' => $v->getName(),
			'id' => $v->getId()
		);
		$this->{xmlWriter}->startTag('request',
			'name' => ($v->getSqlRequest()->getName()),
			'id' => $v->getId()
		);
		$this->{xmlWriter}->startTag('sql');
		$this->{xmlWriter}->cdata($v->getSqlRequest()->getRequest());
		$this->{xmlWriter}->endTag(); # end of sql definition
		
		$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('views_folder') . '/' . $v->getName() . '.sql');
		
		$this->{xmlWriter}->endTag(); # end of request definition
		
		# the rules are exported
		$this->_exportRulesOf($v);
		
		$this->{xmlWriter}->endTag(); # end of view definition
	}
	$this->{xmlWriter}->endTag(); # end of views definition
}

# --------------------------------------------------
# Trigger definitions
# --------------------------------------------------
sub _addTriggerDefinitions {
	my ($this) = @_;

	$this->{xmlWriter}->startTag('triggers');
 	foreach my $t ($this->{model}->getSqlTriggers()) { 
 		$this->{xmlWriter}->startTag('trigger', 
 			'name' => $t->getName(),
			'id' => $t->getId(),
 			'fire' => $t->getFire(),
 			'level' => $t->getLevel()
 		);
 		$this->{xmlWriter}->startTag('table',
 			'name' => $t->getTableReference()->getName(),
 			'id' => $t->getTableReference()->getId()
 		);
	 	$this->{xmlWriter}->endTag();
	 	$this->{xmlWriter}->startTag('events');
	 	foreach my $event ($t->getEvents()) {
	 		$this->{xmlWriter}->startTag('event');
	 		$this->{xmlWriter}->characters($event);
	 		$this->{xmlWriter}->endTag();
	 	}
	 	$this->{xmlWriter}->endTag();	 	
	 	$this->{xmlWriter}->startTag('invokedFunction',
	 		'id' => ($t->getInvokedFunction()->getId()),
	 		'argumentsNumber' => ($t->getInvokedFunction()->getArgumentsNumber()),
	 		'stub' => ($t->getInvokedFunction()->isStub() ? 'true' : 'false')
	 	);
	 	$this->{xmlWriter}->characters($t->getInvokedFunction()->getName());
	 	$this->{xmlWriter}->endTag();

 		$this->{xmlWriter}->startTag('sql');
		$this->{xmlWriter}->cdata($t->getSqlRequest()->getRequest());
		$this->{xmlWriter}->endTag(); # end of sql definition
		
		$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('triggers_folder') . '/' . $t->getName() . '.sql');

 		$this->{xmlWriter}->endTag(); # end of trigger definition		
 	}
	$this->{xmlWriter}->endTag();	# end of triggers definition
}

# --------------------------------------------------
# Sequences
# --------------------------------------------------
sub _addSequences {
	my ($this) = @_;
	$this->{xmlWriter}->startTag('sequences');
 	foreach my $s ($this->{model}->getSequences()) {
 		$this->{xmlWriter}->startTag('sequence', 
 			'name' => $s->getName(),
 			'id' => $s->getId()
 		);
 		$this->{xmlWriter}->endTag();
 	}
 	$this->{xmlWriter}->endTag();	# end of sequences list
}

1;