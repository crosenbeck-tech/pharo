"
A DrTestsUITest is a test class for testing the behavior of DrTestsUI
"
Class {
	#name : #DrTestsUITest,
	#superclass : #TestCase,
	#instVars : [
		'drTestsUI',
		'plugins',
		'plugin1',
		'plugin2'
	],
	#category : #'DrTests-Tests'
}

{ #category : #running }
DrTestsUITest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	super setUp.
	plugin1 := DTTestsRunnerPlugin.
	plugin2 := DTMockPlugin.
	plugins := {plugin1. plugin2}.
	drTestsUI := DrTests on: plugins
]

{ #category : #tests }
DrTestsUITest >> testClickButtonRunCallsPluginRun [
	drTestsUI pluginsDropList selectItem: DTMockPlugin.
	drTestsUI pluginPresenter startButton performAction.
	self assert: drTestsUI currentPlugin hasBeenRun
]

{ #category : #tests }
DrTestsUITest >> testCurrentPluginIsSelectedInDropDown [
	| currentPluginSelected  |
	currentPluginSelected := drTestsUI pluginsDropList selectedItem.
	self
		assert: drTestsUI currentPlugin class
		equals: currentPluginSelected
]

{ #category : #tests }
DrTestsUITest >> testInitialPackagesAreInitialPluginPackages [
	self
		assertCollection: drTestsUI pluginPresenter packagesList items
		hasSameElements: drTestsUI currentPlugin packagesAvailableForAnalysis
]

{ #category : #tests }
DrTestsUITest >> testInitialResultListIsEmpty [

	self assert: drTestsUI pluginPresenter resultsList roots isEmpty
]

{ #category : #tests }
DrTestsUITest >> testInitialSelectedPluginIsFirstPluginInList [

	self assert: drTestsUI currentPlugin class equals: plugins first
]

{ #category : #tests }
DrTestsUITest >> testInitialStatusIsInitialStatusPluginName [
	|status|
	status:= (drTestsUI currentPlugin pluginName , ' plugin is ready to work!') translated.
			
	self
		assert: drTestsUI statusLabel label
		equals: ('{1}: {2}' format: { (drTestsUI  dateAndTimeString ). status }).
]

{ #category : #tests }
DrTestsUITest >> testInitialWindowTitleIsInitialPluginWindowTitle [

	self
		assert: drTestsUI title
		equals: 'Dr Tests - ' , drTestsUI currentPlugin pluginName
]

{ #category : #tests }
DrTestsUITest >> testMultipleSelectingPackagesWillUpdateTheClassesList [
	| currentPluginSelected randomPackage newPackagesSelected classesList packageSelected |
	currentPluginSelected := drTestsUI pluginsDropList selectedItem.
	newPackagesSelected := OrderedCollection new.
	packageSelected := drTestsUI pluginPresenter packagesList items anyOne.
	randomPackage := (drTestsUI pluginPresenter packagesList items
		\ {packageSelected}) anyOne.
	newPackagesSelected add: packageSelected.
	newPackagesSelected add: randomPackage.
	drTestsUI pluginPresenter whenPackagesSelectionChanged: newPackagesSelected.
	classesList := currentPluginSelected new
		itemsToBeAnalysedFor: newPackagesSelected.
	self
		assertCollection: drTestsUI pluginPresenter itemsList items
		hasSameElements: classesList flattened
]

{ #category : #tests }
DrTestsUITest >> testNoPackageSelected [
	self
		assertCollection: drTestsUI pluginPresenter itemsList items
		hasSameElements: #()
]

{ #category : #tests }
DrTestsUITest >> testPluginsAreConfiguredPluginsOnly [
	self
		assert: drTestsUI pluginsDropList listItems asArray
		equals: plugins
]

{ #category : #tests }
DrTestsUITest >> testSelectingPackageWillUpdateTheClassesList [
	| newPackagesSelected |
	newPackagesSelected := {drTestsUI pluginPresenter packagesList items
		anyOne}.
	drTestsUI pluginPresenter whenPackagesSelectionChanged: newPackagesSelected.
	self
		assertCollection: drTestsUI pluginPresenter itemsList items
		hasSameElements: (drTestsUI currentPlugin itemsToBeAnalysedFor: newPackagesSelected)
]

{ #category : #tests }
DrTestsUITest >> testSelectingPluginWillUpdateCurrentPluginInstanceVariable [
	drTestsUI pluginsDropList selectItem: plugin2.
	self assert: drTestsUI currentPlugin class equals: plugin2
]

{ #category : #tests }
DrTestsUITest >> testSelectingPluginWillUpdatePackagesList [
	
	"this test do not has sense anymore (since we do not change package list all the time)"
	self skip. 
	
	drTestsUI pluginsDropList selectItem: plugin2.
	self
		assertCollection: drTestsUI pluginPresenter packagesList items
		hasSameElements:
		drTestsUI currentPlugin packagesAvailableForAnalysis
]

{ #category : #tests }
DrTestsUITest >> testSelectingPluginWillUpdateWindowTitle [
	drTestsUI pluginsDropList selectItem: plugin2.
	self
		assert: drTestsUI title
		equals: 'Dr Tests - ' , drTestsUI currentPlugin pluginName
]

{ #category : #tests }
DrTestsUITest >> testStartButtonHelpIsCurrentPluginStartButtonHelp [
	
	self
		assert: drTestsUI pluginPresenter startButton help
		equals: drTestsUI currentPlugin startButtonHelp
]

{ #category : #tests }
DrTestsUITest >> testStartButtonLabelIsCurrentPluginStartButtonLabel [
	
	self
		assert: drTestsUI pluginPresenter startButton label
		equals: drTestsUI currentPlugin startButtonLabel
]
