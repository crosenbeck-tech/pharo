"
I am the abstract global cluster for CompiledCode classes. I implement shared serialization and materialization behavior.

My instances are looked up in the image, not materialized.

"
Class {
	#name : #FLGlobalCompiledCodeCluster,
	#superclass : #FLGlobalCluster,
	#category : #'Fuel-Core-Clusters-Global'
}

{ #category : #'serialize/materialize' }
FLGlobalCompiledCodeCluster >> materializeGlobalClassFrom: aDecoder [
	| class |
	class := super materializeGlobalClassFrom: aDecoder.
	^ aDecoder nextEncodedByte = true asBit
		ifTrue: [ class classSide ]
		ifFalse: [ class instanceSide ]
]

{ #category : #'serialize/materialize' }
FLGlobalCompiledCodeCluster >> serializeGlobalClass: aClass on: anEncoder [
	super
		serializeGlobalClass: aClass instanceSide
		on: anEncoder. 
	anEncoder encodeByte: aClass isClassSide asBit
]
