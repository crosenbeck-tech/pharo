"
I am responsible for moving a method to class side.

Usage:
| transformation |
transformation := (RBMoveMethodToClassSideTransformation
				method: #method
				class: #RBMoveMethodTransformationTest)
				transform.
(ChangesBrowser changes: transformation model changes changes) open

Preconditions:
- the method exists and belongs to instance side.
"
Class {
	#name : #RBMoveMethodToClassSideTransformation,
	#superclass : #RBMoveMethodToClassTransformation,
	#instVars : [
		'parseTree'
	],
	#category : #'Refactoring2-Transformations-Model'
}

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> accessorsFor: variableName [

	^ RBAddVariableAccessorTransformation 
				model: self model
				variable: variableName
				class: class
				classVariable: false
]

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> addMethod: rbMethod to: aClass toProtocol: protocol [
	aClass addMethod: rbMethod.
	aClass compile: rbMethod source classified: {protocol}.
]

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> checkVariableNamed: aString [
	(class whoDefinesInstanceVariable: aString) ifNotNil: 
			[^ true].
	(class whoDefinesClassVariable: aString) ifNotNil: 
			[^ true].
	^ (self parseTree allDefinedVariables includes: aString)
]

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> getNewInstSideSource [
	| sender |
	sender := ''.
	method argumentNames isNotEmpty ifTrue: [ 
		method selector keywords with: (method argumentNames) do: [:a :b |
		sender := sender, a, ' ', b, ' ']]
	ifFalse: [ sender := method selector ].
	^ sender, '
	^ self class ', sender
]

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> getNewSource [

	| rewriter node temp |
	temp := self temporaryName.
	node := RBParser parseMethod: method source.
	rewriter := RBParseTreeRewriter new replace: 'self' with: temp.
	(rewriter executeTree: node)
		ifTrue: [ 
			node := RBParser parseMethod: rewriter tree formattedCode.
			node body addNodeFirst:
				(RBParser parseExpression: temp , ' := self new').
			node body addTemporaryNamed: temp.
			^ node newSource ]
		ifFalse: [ ^ node sourceCode ]
]

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> parseTree [

	parseTree
		ifNil: [ parseTree := class parseTreeFor: method selector.
			parseTree ifNil: [ self refactoringFailure: 'Could not parse method' ]
			].
	^ parseTree
]

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> preconditions [
	^(RBCondition 
		definesSelector: method selector 
		in: class classSide) not
		& (RBCondition withBlock: [ class isMeta not ])
]

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> privateTransform [
	| oldClass newClass rbMethod rbMethod2 newSource originalProtocol newSource2 |
	newSource := self getNewInstSideSource.
	originalProtocol := method protocol.
	oldClass := class.
	self removeInstVariableReferences.
	method := class methodFor: method selector.
	newClass := self model classNamed: class name, ' class'.
	newSource2 := self getNewSource.
	rbMethod := RBClassModelFactory rbMethod for: newClass source: newSource2 selector: method selector.
	rbMethod2 := RBClassModelFactory rbMethod for: oldClass source: newSource selector: method selector.
	oldClass removeMethod: method selector.
	self addMethod: rbMethod to: newClass toProtocol: originalProtocol.
	self addMethod: rbMethod2 to: oldClass toProtocol: originalProtocol.
]

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> removeInstVariableReferences [
	| rbMethod references |
	rbMethod := (class methodFor: method selector).
	references := class instanceVariableNames select: [:e | rbMethod refersToVariable: e].
	references do: [ :e | |replacer accessorsRefactoring|
		accessorsRefactoring := self accessorsFor: e.
		accessorsRefactoring transform.
		replacer := self parseTreeRewriterClass 
				variable: e
				getter: accessorsRefactoring getterMethod
				setter: accessorsRefactoring setterMethod.
	   self convertMethod: method selector for: class using: replacer ].
]

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' method: '.
	method storeOn: aStream.
	aStream 
		nextPutAll: ' class: ';
		nextPutAll: class name.
	aStream
		nextPutAll: ')'
]

{ #category : #refactoring }
RBMoveMethodToClassSideTransformation >> temporaryName [
	| aString counter tempName |
	counter := 0.
	aString := class canonicalArgumentName.
	tempName := aString.
	[self checkVariableNamed: tempName]
	whileTrue: [ counter := counter + 1.
		tempName := aString , counter asString ].
	^ tempName
]
