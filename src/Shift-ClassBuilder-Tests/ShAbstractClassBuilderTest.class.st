"
Abstract Test class for the Shift Class Builder tests
"
Class {
	#name : #ShAbstractClassBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'result',
		'builder'
	],
	#category : #'Shift-ClassBuilder-Tests-Base'
}

{ #category : #testing }
ShAbstractClassBuilderTest class >> isAbstract [ 
	^ self == ShAbstractClassBuilderTest
]

{ #category : #validation }
ShAbstractClassBuilderTest >> doValidateMethods: selectors on: class [
	| association |
	class methods
		ifNotEmpty: [ association := class methods anyOne classBinding.
			class methods do: [ :method | method classBinding == association ] ].

	selectors
		do: [ :selector | 
			self assert: (class canUnderstand: selector).
			self assert: (class >> selector) classBinding value identicalTo: class ]
]

{ #category : #running }
ShAbstractClassBuilderTest >> setUp [
	super setUp.
	builder := ShiftClassBuilder new.
	builder buildEnvironment: ShSmalltalkGlobalsEnvironment new
]

{ #category : #validation }
ShAbstractClassBuilderTest >> validateClassSideMethods: selectors [
	self doValidateMethods: selectors on: result class
]

{ #category : #validation }
ShAbstractClassBuilderTest >> validateClassSlots: addedSlots superclass: aSuperClass [
	| resultSlots allSlots |
	resultSlots := result class allSlots.
	allSlots := aSuperClass class allSlots , addedSlots.

	self
		assert: resultSlots size = allSlots size
		description: (self comparingCollectionBetween: resultSlots and: allSlots).

	allSlots
		with: resultSlots
		do: [ :a :b | 
			self assert: a name equals: b name.
			self assert: a class equals: b class ]
]

{ #category : #validation }
ShAbstractClassBuilderTest >> validateMethods: selectors [
	self doValidateMethods: selectors on: result
]

{ #category : #validation }
ShAbstractClassBuilderTest >> validateResult [
	| obj |
	self assert: result isClass.
	self assert: result class isMeta.

	obj := result new.
	self assert: obj isNotNil.
	self assert: obj class identicalTo: result
]

{ #category : #validation }
ShAbstractClassBuilderTest >> validateSharedPools: pools [
	self assertCollection: result sharedPools equals: pools asOrderedCollection
]

{ #category : #validation }
ShAbstractClassBuilderTest >> validateSharedVariables: allVariables [
	| resultVariables classVar |
	resultVariables  := result classVarNames.

	self assertCollection: resultVariables equals: allVariables.
	allVariables do: [ :each | 
		classVar := result classVariableNamed: each.
		self assert: classVar definingClass equals: result  ]
]

{ #category : #validation }
ShAbstractClassBuilderTest >> validateSlots: allSlots [
	| resultSlots |
	resultSlots := result allSlots.

	self
		assert: resultSlots size = allSlots size
		description: (self comparingCollectionBetween: resultSlots and: allSlots).

	allSlots
		with: resultSlots
		do: [ :a :b | 
			self assert: a name equals: b name.
			self assert: a class equals: b class ]
]

{ #category : #'private - validating' }
ShAbstractClassBuilderTest >> validateSuperclass: aSuperclass [
	self assert: result superclass identicalTo: aSuperclass
]
