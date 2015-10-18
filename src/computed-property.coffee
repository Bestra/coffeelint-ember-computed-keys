_ = require 'underscore'
{ nodeType, propMatches } = require './util'

quoteRegex = /['"]/g
isSimpleProp = /^['"].+['"]$/

propString = (node) ->
  value = node.base.value
  if value.match(isSimpleProp)
    value.replace(quoteRegex,"")

isGet = (node) ->
  nodeType(node) == "Call" and
  node.variable.this == true and
  propMatches(node, 0, "get")

keyDiff = (bigSet, smallSet) ->
  _.reject bigSet, (b) ->
    _.find(smallSet, (s) -> s.key == b.key)

lineNumber = (node) ->
  node.locationData.first_line + 1
class ComputedProperty
  rootNode: null
  propertyName: null
  dependentKeys: null
  propertyGets: null

  findGets: (blockNode) ->
    accum = []
    blockNode.traverseChildren true, (childNode) =>
      if isGet(childNode)
        accum.push
          key: propString(childNode.args[0])
          lineNumber: lineNumber(childNode)
    _.filter(accum, 'key')

  findDependentKeys: (argNodes) ->
    keys = argNodes.map (keyNode) ->
      key: propString(keyNode)
      lineNumber: lineNumber(keyNode)
    _.filter(keys, 'key')

  constructor: (@propertyName, argNodes, fnBlock) ->
    @dependentKeys = @findDependentKeys(argNodes)
    @propertyGets = @findGets(fnBlock.body)
    @extraKeys = keyDiff(@dependentKeys, @propertyGets)
    @missingKeys = keyDiff(@propertyGets, @dependentKeys)

module.exports = ComputedProperty
