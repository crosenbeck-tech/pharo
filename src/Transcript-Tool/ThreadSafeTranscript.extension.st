Extension { #name : #ThreadSafeTranscript }

{ #category : #'*Transcript-Tool' }
ThreadSafeTranscript >> interactionModel [
	^ self

]

{ #category : #'*Transcript-Tool' }
ThreadSafeTranscript class >> menuCommandOn: aBuilder [
	<worldMenu>
	(aBuilder item: #'Transcript')
		action: [ Smalltalk tools transcript open ];
		order: 2;
		parent: #InputOutput;
		help: 'Transcript';
		keyText: 'o, t';
		help: 'Window on the Transcript output stream, which is useful for writing log messages.';
		icon: (aBuilder iconNamed: self taskbarIconName).
	aBuilder withSeparatorAfter

]

{ #category : #'*Transcript-Tool' }
ThreadSafeTranscript >> open [
	<script: 'self new open'>
	
	^ self openLabel: self title

]

{ #category : #'*Transcript-Tool' }
ThreadSafeTranscript class >> open [ 
	<script>
	
	^ self new open 

]

{ #category : #'*Transcript-Tool' }
ThreadSafeTranscript >> openLabel: aString [
	| window m |
	window := (SystemWindow labelled: aString) model: self.
	m := RubPluggableTextMorph new
		getTextSelector: #contents;
		setTextSelector: #clear;
		on: self;
		beForSmalltalkScripting.
	m onAnnouncement: MorphDeleted do: [ self announcer unsubscribe: m  ].
	window addMorph: m frame: (0 @ 0 corner: 1 @ 1).
	^ window openInWorld

]
