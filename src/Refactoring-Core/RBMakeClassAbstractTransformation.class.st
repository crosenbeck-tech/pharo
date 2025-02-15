Class {
	#name : #RBMakeClassAbstractTransformation,
	#superclass : #RBClassRefactoring,
	#instVars : [
		'targetClass'
	],
	#category : #'Refactoring-Core-Transformation'
}

{ #category : #displaying }
RBMakeClassAbstractTransformation class >> basicMenuItemString [

	^ 'Make abstract'
]

{ #category : #'instance creation' }
RBMakeClassAbstractTransformation class >> class: targetClass [

	^ self new class: targetClass 
]

{ #category : #testing }
RBMakeClassAbstractTransformation class >> isTransformation [ 

	^ true
]

{ #category : #'instance creation' }
RBMakeClassAbstractTransformation >> class: class [

	targetClass := class
]

{ #category : #preconditions }
RBMakeClassAbstractTransformation >> preconditions [
	
	^ (RBCondition isAbstractClass: targetClass) not
]

{ #category : #transforming }
RBMakeClassAbstractTransformation >> transform [
	(RBAddMethodTransformation
		                   sourceCode: 'isAbstract
		
	^ self == ' , targetClass asString
		                   in: targetClass classSide
		                   withProtocols: #( #testing )) execute
]
