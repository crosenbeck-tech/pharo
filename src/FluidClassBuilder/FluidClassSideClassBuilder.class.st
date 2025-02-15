"
I'm a builder responsible for handling the specific case of 

```
Object class >> Point class
	slots: ;
	traits: ....;
```

We want to make sure that we are not forced to use classSlots: and classTraits: 
because users will be confused. 
"
Class {
	#name : #FluidClassSideClassBuilder,
	#superclass : #FluidClassBuilder,
	#category : #'FluidClassBuilder-Base'
}

{ #category : #API }
FluidClassSideClassBuilder >> slots: anArray [
	"Pay attention on the class side we do not have to have classSlots: but slots:"
	
	classSlotsToBuild := anArray collect: [ :each | each asSlot ]
]

{ #category : #API }
FluidClassSideClassBuilder >> traits: aCollection [
	"Pay attention that on class side we want to write traits: and not classTraits:"
	
	classTraitsToBuild := aCollection asTraitComposition
]
