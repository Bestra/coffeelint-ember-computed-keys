assert = require('assert')
coffeelint = require('coffeelint')
plugin = require('../index')
coffeelint.registerRule(plugin)
config = {}

assertNoError = (input) ->
  errors = coffeelint.lint(input, config)
  assert.equal(errors.length, 0)

describe "integration", ->
  it "reports errors for unused keys", ->
    testString = """
    Ember.Object.create
      prop1: Ember.computed 'dep1', 'dep2', ->
        @get('dep1')
    """

    errors = coffeelint.lint(testString, config)
    assert.equal(errors.length, 1, "it produces 1 error")
    assert.equal(errors[0].meta, "unusedKey", "it has the correct meta")

  it "reports errors for @get() call lacking corresponding keys", ->
    testString = """
    Ember.Object.create
      prop1: Ember.computed 'dep1', ->
        @get('dep1') + @get('dep2')
    """

    errors = coffeelint.lint(testString, config)
    assert.equal(errors.length, 1, "it produces 1 error")
    assert.equal(errors[0].meta, "needsKey")

  it "works for property extensions", ->
    testString = """
    Ember.Object.create
      prop1: ( ->
        @get('dep1')
      ).property('dep1', 'dep2')
    """

    errors = coffeelint.lint(testString, config)
    assert.equal(errors.length, 1, "it produces 1 error")
    assert.equal(errors[0].meta, "unusedKey")

  it "works with double-quoted keys too", ->
    testString = """
    Ember.Object.create
      prop1: Em.computed "dep1", "dep2", ->
        @get('dep1')
    """

    errors = coffeelint.lint(testString, config)
    assert.equal(errors.length, 1, "it produces 1 error")
    assert.equal(errors[0].meta, "unusedKey")

  it "dependent keys that are not string literals are ignored", ->
    testString = """
    Ember.Object.create
      prop1: Em.computed "dep1", someVariable, ->
        @get("dep1")
    """
    assertNoError(testString)

  it "@get() calls that are made with a variable are ignored", ->
    testString = """
    Ember.Object.create
      prop1: Em.computed "dep1", ->
        @get("dep1") + @get(anotherVariable)
    """
    assertNoError(testString)

  it "multiple @get() calls that use the same key are ignored", ->
    testString = """
    Ember.Object.create
      prop1: Em.computed "dep1", ->
        @get("dep1") + @get("dep1")
    """
    assertNoError(testString)

  describe "Array Properties", ->
    it "dependent key 'foo.[]' needs a call to @get('foo*') in the body"
    it "dependent key 'foo.@each.*' needs @get('foo*') in the body"

  describe "Bracket expansion", ->
    it "dependent key 'foo.{bar,baz}' needs @get('foo.bar') and @get('foo.baz') in the body"
