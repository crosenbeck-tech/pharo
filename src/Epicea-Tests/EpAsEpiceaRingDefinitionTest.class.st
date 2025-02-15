Class {
	#name : #EpAsEpiceaRingDefinitionTest,
	#superclass : #TestCase,
	#category : #'Epicea-Tests-Model'
}

{ #category : #running }
EpAsEpiceaRingDefinitionTest >> definitions [
	"FIX: it should not have this external dependency to Fuel code entities."

	^ {	(FLSerializer >> #serialize).
		(Object >> #fuelAccept:).
		FLSerializer.
		FLSerializer class. 
		FLTGlobalClassOrTraitSerializationTest.
		FLTGlobalClassOrTraitSerializationTest classTrait.
		} collect: [:each | each asEpiceaRingDefinition]
]

{ #category : #tests }
EpAsEpiceaRingDefinitionTest >> testPackageIsString [

	self definitions do: [ :each |
		self assert: each package isString.
		self assert: each package isNotEmpty ]
]
