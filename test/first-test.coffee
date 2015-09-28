assert = require('assert')
coffeelint = require('coffeelint')
plugin = require('../index')
coffeelint.registerRule(plugin)
config = {}

describe "tldr tests", ->
  it "reports errors for unused keys", ->
    missingProp = """
    Ember.Object.create
      prop1: Ember.computed 'dep1', 'dep2', ->
        @get('dep1')
    """

    errors = coffeelint.lint(missingProp, config)
    assert(errors.length == 1, "it produces 1 error")
    assert.equal(errors[0].meta, "unusedKey", "it has the correct meta")

  it "works for Em.computed", ->
    missingProp = """
    Ember.Object.create
      prop1: Em.computed 'dep1', 'dep2', ->
        @get('dep1')
    """

    errors = coffeelint.lint(missingProp, config)
    assert(errors.length == 1, "it produces 1 error")
    assert.equal(errors[0].meta, "unusedKey", "it has the correct meta")

  it.only "works for property extensions", ->
    missingProp = """
    Ember.Object.create
      prop1: ( ->
        @get('dep1')
      ).property('dep1', 'dep2')
    """

    errors = coffeelint.lint(missingProp, config)
    assert(errors.length == 1, "it produces 1 error")
    assert.equal(errors[0].meta, "unusedKey", "it has the correct meta")

  it "reports errors for @get() call lacking corresponding keys", ->
    missingProp = """
    Ember.Object.create
      prop1: Ember.computed 'dep1', ->
        @get('dep1') + @get('dep2')
    """

    errors = coffeelint.lint(missingProp, config)
    assert(errors.length == 1, "it produces 1 error")
    assert.equal(errors[0].meta, "needsKey", "it has the correct meta")

  it "reports errors for @get() call lacking corresponding keys", ->
    missingProp = """
    Ember.Object.create
      prop1: Ember.computed 'dep1', ->
        @get('dep1') + @get('dep2')
    """

    errors = coffeelint.lint(missingProp, config)
    assert(errors.length == 1, "it produces 1 error")
    assert.equal(errors[0].meta, "needsKey", "it has the correct meta")
