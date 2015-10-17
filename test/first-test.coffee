assert = require('assert')
coffeelint = require('coffeelint')
plugin = require('../index')
coffeelint.registerRule(plugin)
config = {}

describe "integration", ->
  it "reports errors for unused keys", ->
    missingProp = """
    Ember.Object.create
      prop1: Ember.computed 'dep1', 'dep2', ->
        @get('dep1')
    """

    errors = coffeelint.lint(missingProp, config)
    assert.equal(errors.length, 1, "it produces 1 error")
    assert.equal(errors[0].meta, "unusedKey", "it has the correct meta")

  it "reports errors for @get() call lacking corresponding keys", ->
    missingProp = """
    Ember.Object.create
      prop1: Ember.computed 'dep1', ->
        @get('dep1') + @get('dep2')
    """

    errors = coffeelint.lint(missingProp, config)
    assert.equal(errors.length, 1, "it produces 1 error")
    assert.equal(errors[0].meta, "needsKey", "it has the correct meta")

  it "works for Em.computed", ->
    missingProp = """
    Ember.Object.create
      prop1: Em.computed 'dep1', 'dep2', ->
        @get('dep1')
    """

    errors = coffeelint.lint(missingProp, config)
    assert.equal(errors.length, 1, "it produces 1 error")
    assert.equal(errors[0].meta, "unusedKey", "it has the correct meta")

  it "works for property extensions", ->
    missingProp = """
    Ember.Object.create
      prop1: ( ->
        @get('dep1')
      ).property('dep1', 'dep2')
    """

    errors = coffeelint.lint(missingProp, config)
    assert.equal(errors.length, 1, "it produces 1 error")
    assert.equal(errors[0].meta, "unusedKey", "it has the correct meta")

  it "works with double-quoted keys too", ->
    missingProp = """
    Ember.Object.create
      prop1: Em.computed "dep1", "dep2", ->
        @get('dep1')
    """

    errors = coffeelint.lint(missingProp, config)
    assert.equal(errors.length, 1, "it produces 1 error")
    assert.equal(errors[0].meta, "unusedKey", "it has the correct meta")

  it "dependent keys that are not string literals are ignored", ->
    missingProp = """
    Ember.Object.create
      prop1: Em.computed "dep1", someVariable, ->
        @get("dep1")
    """

    errors = coffeelint.lint(missingProp, config)
    assert.equal(errors.length, 0)

  it "@get() calls that are made with a variable are ignored", ->
    missingProp = """
    Ember.Object.create
      prop1: Em.computed "dep1", ->
        @get("dep1") + @get(anotherVariable)
    """

    errors = coffeelint.lint(missingProp, config)
    assert.equal(errors.length, 0)

  it "multiple @get() calls that use the same key are ignored", ->
    missingProp = """
    Ember.Object.create
      prop1: Em.computed "dep1", ->
        @get("dep1") + @get("dep1")
    """

    errors = coffeelint.lint(missingProp, config)
    assert.equal(errors.length, 0)

  describe "Array Properties", ->
    it "dependent key 'foo.[]' needs a call to @get('foo*') in the body"
    it "dependent key 'foo.@each.*' needs @get('foo*') in the body"
  describe "Bracket expansion", ->
    it "dependent key 'foo.{bar,baz}' needs @get('foo.bar') and @get('foo.baz') in the body"
