"
I'm parser for the new class syntax. 


### The new syntax for class definition (just for the class and not for the methods) is

```
Superclass < #MyObject
	uses: #MyTrait;
	slots: { #a. #b };
	sharedVariables: { #A. #B };
	tags: {'tag2' . 'Core'} ;
	layout: VariableLayout; 
	sharedPools: { #TextConstants } ;
	package: #MyPackage
```
Pay attention all the messages should be keyword-based.

The minimal class definition is the following one: 

```
Superclass < #MyObject
	package: #MyPackage
```

For the implementors, we see that we should either handle a simple message composition or a cascade. 

### Design Concerns 
Note that sending a message to the superclass is close to subclass: and it lets the class selects 
a class definition parser if the syntax should be extended. 
In addition having a binary message makes () unneccessary.


"
Class {
	#name : #CDFluidClassDefinitionParser,
	#superclass : #CDAbstractClassDefinitionParser,
	#instVars : [
		'classNameNode',
		'superclassNode'
	],
	#category : #'ClassParser-Parser'
}

{ #category : #parsing }
CDFluidClassDefinitionParser >> handleClassAndSuperclassOf: aNode [

	superclassNode ifNotNil: [ self handleSuperclassNode: superclassNode ].
	self handleClassName: classNameNode.
]

{ #category : #parsing }
CDFluidClassDefinitionParser >> handleLayout: aNode [
	classDefinition layoutClass: aNode binding value
]

{ #category : #parsing }
CDFluidClassDefinitionParser >> handleMetaclassNameFromCascade: aRBCascadeNode [ 

	| className classNode node |
	node := aRBCascadeNode receiver arguments first. 
	className := node receiver binding value class name.
	classNode := self classNameNodeClass new
		originalNode: node;
		className: className.
	classDefinition className: node astNode: classNode
]

{ #category : #parsing }
CDFluidClassDefinitionParser >> handleMetaclassNameFromMessage: aNode [ 

	| className classNode node |
	node := aNode arguments first receiver. 
	className := node binding value class name.
	classNode := self classNameNodeClass new
		originalNode: node;
		className: className.
	classDefinition className: node astNode: classNode
]

{ #category : #parsing }
CDFluidClassDefinitionParser >> handleSharedPoolsFromNode: aNode [
	| sharedPoolNodes |
	sharedPoolNodes := aNode children
		collect: [ :aPoolNode | 
			self sharedPoolNodeClass
				node: aPoolNode
				name: aPoolNode name
				start: aPoolNode start 
				stop: aPoolNode start + aPoolNode name size
			].
	classDefinition sharedPools: sharedPoolNodes
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSharedVarableNodeSimple: slotDefNode [

	"when a class variable is just #Name"

	^ CDSharedVariableNode new
		  node: slotDefNode;
		  name: slotDefNode value;
		  variableClassName: #ClassVariable;
		  start: slotDefNode start;
		  stop: slotDefNode stop
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSharedVariabeNode: variableDefNode [
	 | variable |
	"when a class variable is just #ClassVars"
	variableDefNode isLiteralNode ifTrue: [ variable := self handleSharedVarableNodeSimple: variableDefNode].
	"#ClassVar => SomeVar default: 5; default2: 4"
	variableDefNode isCascade ifTrue: [ variable := self handleSharedVariableNodeCascade: variableDefNode].
	"when a class var is just #var => SomeVar"
	(variableDefNode isMessage and: [ variableDefNode selector = '=>'  ])ifTrue: [  variable := self handleSharedVariableNodeSimpleClass: variableDefNode].
	"When a class variable is #Var => SomeVar default: 5"
	(variableDefNode isMessage and: [ variableDefNode selector ~= '=>'  ]) ifTrue:  [ variable := self handleSharedVariableNodeSimpleClassArgument: variableDefNode].
	
	variable ifNil: [ ^self error: 'Variable definion can not be parsed' ].
	classDefinition addSharedVariable: variable

]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSharedVariableNodeCascade: slotDefNode [

	"#ClassVar => SomeVar default: 5; default2: 4"

	^ CDSharedVariableNode new
		  node: slotDefNode;
		  name: slotDefNode receiver receiver value;
		  variableClassName: slotDefNode receiver arguments first value name;
		  start: slotDefNode start;
		  stop: slotDefNode stop
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSharedVariableNodeSimpleClass: slotDefNode [

	"when a calss var is just #var => SomeVar"

	^ CDSharedVariableNode new
		  node: slotDefNode;
		  name: slotDefNode receiver value;
		  variableClassName: slotDefNode arguments first name;
		  start: slotDefNode start;
		  stop: slotDefNode stop
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSharedVariableNodeSimpleClassArgument: slotDefNode [

	"When a class variable is #Var => SomeVar default: 5"

	^ CDSharedVariableNode new
		  node: slotDefNode;
		  name: slotDefNode receiver receiver value;
		  variableClassName: slotDefNode receiver arguments first name;
		  start: slotDefNode start;
		  stop: slotDefNode stop
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSharedVariableNodesFromArrayNode: aRBArrayNode [
	
	aRBArrayNode statements do: [ :slotStatement |
		self handleSharedVariabeNode: slotStatement ]
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSlotNode: slotDefNode [
	 | slot |
	"when a slot is just #inst"
	slotDefNode isLiteralNode ifTrue: [ slot := self handleSlotNodeSimple: slotDefNode].
	"#inst => InstanceVariableSlot default: 5; default2: 4"
	slotDefNode isCascade ifTrue: [ slot := self handleSlotNodeCascade: slotDefNode].
	"when a slot is just #inst => InstanceVariableSlot."
	(slotDefNode isMessage and: [ slotDefNode selector = '=>'  ])ifTrue: [  slot := self handleSlotNodeSimpleClass: slotDefNode].
	"when a slot is #inst => InstanceVariableSlot default: 5."
	(slotDefNode isMessage and: [ slotDefNode selector ~= '=>'  ]) ifTrue:  [ slot := self handleSlotNodeSimpleClassArgument: slotDefNode].
	
	slot ifNil: [ ^self error: 'Slot definion can not be parsed' ].
	classDefinition addSlot: slot
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSlotNodeCascade: slotDefNode [

	"#inst => InstanceVariableSlot default: 5; default2: 4"

	^ CDSlotNode new
		  node: slotDefNode;
		  name: slotDefNode receiver receiver value;
		  variableClassName: slotDefNode receiver arguments first value name;
		  start: slotDefNode start;
		  stop: slotDefNode stop
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSlotNodeSimple: slotDefNode [

	"when a slot is just #inst"

	^ CDSlotNode new
		  node: slotDefNode;
		  name: slotDefNode value;
		  variableClassName: #InstanceVariableSlot;
		  start: slotDefNode start;
		  stop: slotDefNode stop
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSlotNodeSimpleClass: slotDefNode [

	"when a variable is just #var => InstanceVariableSlot"

	^ CDSlotNode new
		  node: slotDefNode;
		  name: slotDefNode receiver value;
		  variableClassName: slotDefNode arguments first name;
		  start: slotDefNode start;
		  stop: slotDefNode stop
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSlotNodeSimpleClassArgument: slotDefNode [

	"When a vaiable is #var => InstanceVariableSlot default: 5"

	^ CDSlotNode new
		  node: slotDefNode;
		  name: slotDefNode receiver receiver value;
		  variableClassName: slotDefNode receiver arguments first name;
		  start: slotDefNode start;
		  stop: slotDefNode stop
]

{ #category : #'parsing - variables' }
CDFluidClassDefinitionParser >> handleSlotsNodesFromArrayNode: aRBArrayNode [
	
	aRBArrayNode statements do: [ :slotStatement |
		self handleSlotNode: slotStatement ]
]

{ #category : #parsing }
CDFluidClassDefinitionParser >> handleSuperclassNode: aSuperclassNode [
	| aSuperclassName newSuperclassNode |

	aSuperclassName := aSuperclassNode isLiteralNode
		ifTrue: [ nil ]
		ifFalse: [ aSuperclassNode binding value asString asSymbol ].
	newSuperclassNode := self classNameNodeClass new
		originalNode: aSuperclassNode;
		className: aSuperclassName.
	classDefinition
		superclassName: aSuperclassName
		astNode: newSuperclassNode
]

{ #category : #parsing }
CDFluidClassDefinitionParser >> handleTag: aNode [

	classDefinition tag: (CDClassTagNode new name: aNode value)
]

{ #category : #parsing }
CDFluidClassDefinitionParser >> parseRootNode: expressionTree [
	
	| searcher |
	searcher := RBParseTreeSearcher new.
	searcher
		matches: 'Trait << `#name' do: [:aNode :answer | 
			classNameNode := searcher variableNamed: '`#name'.
			self beTraitDefinition ];
		matches: 'Trait << `name classTrait' do: [:aNode :answer | 
			classNameNode := searcher variableNamed: '`name'.
			self beClassSideTraitDefinition ];
		matches: '`superclass << `#name' do: [:aNode :answer | 
			classNameNode := searcher variableNamed: '`#name'.			
			superclassNode := searcher variableNamed: '`superclass'.
			self beClassDefinition ];
		matches: '`superclass class << `name class' do: [:aNode :answer | 
			classNameNode := searcher variableNamed: '`name'.			
			self beMetaclassDefinition ].
		
	searcher executeTree: expressionTree.
	
	classDefinition originalNode: expressionTree.
	expressionTree acceptVisitor: self.
	^ classDefinition
]

{ #category : #parsing }
CDFluidClassDefinitionParser >> parseSelectorPart: aString withArgument: aNode [ 
	"We could do this with reflection, or with a dictionary and closures.
	I chose to use a series of if for readability only."
	
	aString =	 #slots:
		ifTrue: [ ^ self handleSlotsNodesFromArrayNode: aNode ].
	aString =	 #sharedVariables: 
		ifTrue: [ ^ self handleSharedVariableNodesFromArrayNode: aNode ].	
	aString =	 #package:
		ifTrue: [ ^ self handlePackage: aNode ].
	aString = #layout:
		ifTrue: [ ^ self handleLayout: aNode ].	
	aString = #tag: 
		ifTrue: [  ^self handleTag: aNode ].
	aString =	 #traits:
		ifTrue: [ ^ self handleTraitUsesFromNode: aNode ].
	aString =	 #sharedPools:
		ifTrue: [ ^ self handleSharedPoolsFromNode: aNode ].
	
	CDUnrecognizedClassPart new
		classDefinition: self; 
		unrecognizedPart: aString;
		signal
]

{ #category : #parsing }
CDFluidClassDefinitionParser >> visitCascadeNode: aRBCascadeNode [ 
	"See class comment. Here we handle the cascade version of the class definition."
	" 
	Object << #Point
			trait: TraitX;
			slots: { #foo };
			package: ''Kernel-BasicObjects'''
	"
	
	self handleClassAndSuperclassOf: aRBCascadeNode.	
	aRBCascadeNode messages do: 
		[:msg | msg selectorParts
					with: msg arguments
					do: [ :selectorPart :argument |
			self parseSelectorPart: selectorPart withArgument: argument ] ]
]

{ #category : #parsing }
CDFluidClassDefinitionParser >> visitMessageNode: aRBMessageNode [
	"See class comment. Here we handle the cascade version of the class definition."
	"
	Object << #Point
			package: ''Kernel-BasicObjects'''
	"		

	self handleClassAndSuperclassOf: aRBMessageNode.
	
	aRBMessageNode arguments ifEmpty: [ ^ self ].
	aRBMessageNode selectorParts
		with: aRBMessageNode arguments
		do: [ :selectorPart :argument |
			self parseSelectorPart: selectorPart withArgument: argument ]
]
