"
Instance variables 
- contoursSize - The number of contours in the outline.
- pointsSize - The number of points in the outline.
- points - an array of  26.6 fixed point integer pairs giving the outline's point coordinates.
- tags 	- an array of pointsSize bytes, giving each outline point's type. 

counting from 0
If bit 0 is unset, the point is 'off' the curve, i.e., a Bézier control point, while it is 'on' when set.
Bit 1 is meaningful for 'off' points only. If set, it indicates a third-order Bézier arc control point; and a second-order control point if unset.

instVar: contours - an array of contoursSize shorts, giving the end point of each contour within the outline. For example, the first contour is defined by the points '0' to 'contours[0]', the second one is defined by the points 'contours[0]+1' to 'contours[1]', etc.

instVar: flags - a set of bit flags used to characterize the outline and give hints to the scan-converter and hinter on how to convert/grid-fit it.

"
Class {
	#name : #FT2Outline,
	#superclass : #Object,
	#instVars : [
		'contoursSize',
		'pointsSize',
		'points',
		'tags',
		'contours'
	],
	#category : #'FreeType-Base'
}

{ #category : #private }
FT2Outline >> allocateArrays [
	" allocate the arrays for the primLoadArraysFrom:"
	points := 	IntegerArray new: pointsSize * 2.
	tags := 		ByteArray new: pointsSize.
	contours := 	ShortIntegerArray new: contoursSize.
]

{ #category : #accessing }
FT2Outline >> contoursCollection [
	"returns a list of contours with tag => points list pairs"
	| allPoints result start end |
	allPoints := self pointCollection.
	
	result := OrderedCollection new.
	start := 1.
	"no normal iteration because contours size can be bigger than contourSize"
	1 to: contoursSize do: [ :i |
		end := (contours at: i) + 1. "c converion"
		result add: ((tags copyFrom: start to: end) ->  (allPoints copyFrom: start to: end)).
		start := end + 1.
	].

	^result
]

{ #category : #accessing }
FT2Outline >> pointCollection [

	^(1 to: pointsSize * 2 by: 2) collect: [ :i | ((points at: i) / 64) @ ((points at: i + 1) / 64)]
]

{ #category : #private }
FT2Outline >> primLoadArraysFrom: anFT2Face [
	| outline contoursArray pointsArray |
	outline := anFT2Face outline.
	contoursArray := FFIExternalArray externalNewType: 'short' size: outline n_contours.
	
	1 to: outline n_contours do: [ :idx |
		contours at: 1 put: (contoursArray at: 1).	
	].

	pointsArray := FFIExternalArray externalNewType: 'int' size: outline n_points * 2.

	1 to: (outline n_points * 2) do: [ :idx |
		points at: 1 put: (pointsArray at: 1).
	].
]

{ #category : #private }
FT2Outline >> primLoadSizesFrom: anFT2Face [
	
	contoursSize := anFT2Face outline n_contours.
	pointsSize := anFT2Face outline n_points.
]
