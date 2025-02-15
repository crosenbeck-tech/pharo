"
I am the command allowing one to debug a failing test.
"
Class {
	#name : #DTDebugTestCommand,
	#superclass : #DTLeafResultCommand,
	#category : #'DrTests-TestsRunner-Commands'
}

{ #category : #hooks }
DTDebugTestCommand >> canBeRun [
	^ super canBeRun and: [ self resultSelected type isPass not ]
]

{ #category : #hooks }
DTDebugTestCommand >> execute [
	self resultSelected content debug
]

{ #category : #initialization }
DTDebugTestCommand >> initialize [
	
	super initialize.
	self
		name: 'Debug test';
		description: 'Re-run the test selected and opens a debugger when an assertion fails.'
]
