Class {
	#name : #OmFileStoreTest,
	#superclass : #OmStoreTest,
	#category : #'Ombu-Tests'
}

{ #category : #resources }
OmFileStoreTest >> setUpOtherStore [

	^ OmFileStore 
		named: 'testingOtherStore', UUID new asString36
		inDirectory: self directoryForTests ensureCreateDirectory
]

{ #category : #resources }
OmFileStoreTest >> setUpStore [	

	^ OmFileStore 
		named: 'testingStore', UUID new asString36
		inDirectory: self directoryForTests ensureCreateDirectory
]

{ #category : #running }
OmFileStoreTest >> tearDown [
	
	store fileReference ensureDelete.
	otherStore fileReference ensureDelete.
	super tearDown
]

{ #category : #tests }
OmFileStoreTest >> testEnsureDeleteFile [
	| loadedStore |
	store newEntry: (OmEntry content: 42).
	store flush.

	store ensureDeleteFile.
	
	loadedStore := 
		(OmFileStore 
			named: store globalName 
			inDirectory: self directoryForTests)
			refresh;
			yourself.
	
	self assert: loadedStore entriesCount equals: 0.
]

{ #category : #tests }
OmFileStoreTest >> testIsOutdated [

	| copy |
	self deny: store isOutdated.
	store newEntry: (OmEntry content: 42).
	self deny: store isOutdated.
	store flush.
	self deny: store isOutdated.
	copy := store copyReopened refresh.
	store newEntry: (OmEntry content: 43).
	store flush.
	"A store is outdated if the file exists and has greater size than in memory."
	self assert: copy isOutdated.
	store ensureDeleteFile.
	self deny: copy isOutdated.
]

{ #category : #tests }
OmFileStoreTest >> testLoadFromCorruptFile1 [
	"Bad character"

	| loadedStore |
	store newEntry: (OmEntry content: 41).
	store newEntry: (OmEntry content: 42).

	"Override first characters"
	store fileReference writeStreamDo: [ :stream | stream nextPutAll: '***' ].
	
	loadedStore := 
		(OmFileStore 
			named: store globalName 
			inDirectory: self directoryForTests)
			yourself.
	
	self 
		should: [ loadedStore refresh; entries ]
		raise: OmFileStoreReadingError
]

{ #category : #tests }
OmFileStoreTest >> testLoadFromCorruptFile2 [
	"Bad class name"

	| loadedStore |
	store newEntry: (OmEntry content: 41).
	store newEntry: (OmEntry content: 42).

	"Override first characters"
	store fileReference writeStreamDo: [ :stream | stream nextPutAll: 'OMENTRY' ].
	
	loadedStore := 
		(OmFileStore 
			named: store globalName 
			inDirectory: self directoryForTests)
			yourself.
	
	self 
		should: [ loadedStore refresh; entries ]
		raise: OmFileStoreReadingError
]

{ #category : #tests }
OmFileStoreTest >> testLoadFromCorruptFile3 [
	"Bad class name. Last entry."

	| loadedStore |
	store newEntry: (OmEntry content: 41).

	"Override first characters"
	store fileReference writeStreamDo: [ :stream | stream nextPutAll: 'OMENTRY' ].
	
	loadedStore := 
		(OmFileStore 
			named: store globalName 
			inDirectory: self directoryForTests)
			yourself.
	
	self 
		should: [ loadedStore refresh; entries ]
		raise: OmFileStoreReadingError
]

{ #category : #tests }
OmFileStoreTest >> testLoadFromCorruptFile4 [
	"Content is corrupted"

	| loadedStore stream |
	store newEntry: (OmEntry content: 41).
	store newEntry: (OmEntry content: 42).
	store flush.
	
	"Override first characters"
	stream := store fileReference binaryWriteStream.
	[
		(ZnCharacterWriteStream on: stream encoding: 'utf8')
			position: 50;
			nextPutAll: '**'.
			
		"Apparently, in Linux it can randomly fail if not explicitly flush"
		stream flush.
	] ensure: [ stream close ].
	
	loadedStore := 
		(OmFileStore 
			named: store globalName 
			inDirectory: self directoryForTests)
			yourself.
	
	self 
		should: [ loadedStore refresh; entries ]
		raise: OmFileStoreReadingError.
]

{ #category : #tests }
OmFileStoreTest >> testLoadFromFile [
	| loadedStore |
	store newEntry: (OmEntry content: 42).
	store flush.
	
	loadedStore := 
		(OmFileStore 
			named: store globalName 
			inDirectory: self directoryForTests)
			refresh;
			yourself.
	
	self 
		assert: (loadedStore entries collect: #content as: Array)
		equals: #(42)
]
