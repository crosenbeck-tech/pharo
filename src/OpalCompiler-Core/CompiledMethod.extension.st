Extension { #name : #CompiledMethod }

{ #category : #'*OpalCompiler-Core' }
CompiledMethod >> decompile [
	^Smalltalk globals 
		at: #FBDDecompiler
		ifPresent: [ :decompiler | decompiler new  decompile: self]  
		ifAbsent: [ RBParser parseMethod: self selector asMethodPreamble, '
	self noSourceAvailable' ]
]

{ #category : #'*OpalCompiler-Core' }
CompiledMethod >> decompileIR [
	
	^ IRBytecodeDecompiler new decompile: self
]

{ #category : #'*OpalCompiler-Core' }
CompiledMethod >> methodNode [
	"returns an AST for this method, do not cache it. (see #ast for the cached alternative)"
	^self parseTree
]

{ #category : #'*OpalCompiler-Core' }
CompiledMethod >> recompile [
	^ self methodClass recompile: self selector
]

{ #category : #'*OpalCompiler-Core' }
CompiledMethod >> reformat [
	self methodClass compile: self ast formattedCode classified:  self category.
]

{ #category : #'*OpalCompiler-Core' }
CompiledMethod >> sourceNode [
	^self ast
]

{ #category : #'*OpalCompiler-Core' }
CompiledMethod >> sourceNodeForPC: aPC [
	^self sourceNode sourceNodeForPC: aPC
]
