"
I was used for the left arrow assignment (the ASCII underscore character) operator.
In the current scanner/parser, this assignment operator is not used or allowed anymore.
"
Class {
	#name : #RBShortAssignmentToken,
	#superclass : #RBAssignmentToken,
	#category : #'AST-Core-Tokens'
}

{ #category : #accessing }
RBShortAssignmentToken >> length [

	^ 1
]
