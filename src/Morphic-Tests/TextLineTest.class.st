Class {
	#name : #TextLineTest,
	#superclass : #HashAndEqualsTestCase,
	#category : #'Morphic-Tests-Text Support'
}

{ #category : #running }
TextLineTest >> setUp [
	super setUp.
	prototypes
		add: (TextLine
				start: 1
				stop: 50
				internalSpaces: 2
				paddingWidth: 1)
]
