_ = require 'underscore'
{ nodeType, propMatches } = require './util'

propString = (node) -> node.base.value.replace(/['"]/g,"")

isGet = (node) ->
  nodeType(node) == "Call" and
  node.variable.this == true and
  propMatches(node, 0, "get")

class ComputedProperty
  rootNode: null
  propertyName: null
  dependentKeys: null
  propertyGets: null

  findGets: (blockNode) ->
    blockNode.traverseChildren true, (childNode) =>
      if isGet(childNode)
        @propertyGets.push
          key: propString(childNode.args[0])
          lineNumber: childNode.locationData.first_line + 1

  keyDiff: (bigSet, smallSet) ->
    _.reject bigSet, (b) ->
      _.find(smallSet, (s) -> s.key == b.key)

  constructor: (@propertyName, argNodes, fnBlock) ->
    @dependentKeys = argNodes.map (keyNode) ->
      key: propString(keyNode)
      lineNumber: keyNode.locationData.first_line + 1

    @propertyGets = []

    @findGets(fnBlock.body)

    @extraKeys = @keyDiff(@dependentKeys, @propertyGets)
    @missingKeys = @keyDiff(@propertyGets, @dependentKeys)

module.exports = ComputedProperty
