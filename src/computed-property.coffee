_ = require 'underscore'
{ nodeType, propMatches } = require './util'

quoteRegex = /['"]/g
propString = (node) ->
  value = node.base.value
  if value.match(quoteRegex)
    value.replace(quoteRegex,"")

isGet = (node) ->
  nodeType(node) == "Call" and
  node.variable.this == true and
  propMatches(node, 0, "get")

keyDiff = (bigSet, smallSet) ->
  _.reject bigSet, (b) ->
    _.find(smallSet, (s) -> s.key == b.key)

removeEmptyKeys = (arr) ->
  _.reject(arr, (item) -> !item.key)

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


  constructor: (@propertyName, argNodes, fnBlock) ->
    @dependentKeys = argNodes.map (keyNode) ->
      key: propString(keyNode)
      lineNumber: keyNode.locationData.first_line + 1

    @propertyGets = []
    @findGets(fnBlock.body)
    @dependentKeys = removeEmptyKeys(@dependentKeys)
    @propertyGets = removeEmptyKeys(@propertyGets)
    @extraKeys = keyDiff(@dependentKeys, @propertyGets)
    @missingKeys = keyDiff(@propertyGets, @dependentKeys)

module.exports = ComputedProperty
