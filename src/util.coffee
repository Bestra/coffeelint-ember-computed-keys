_ = require 'underscore'

nodeType = (node) ->
  node.constructor.name

propMatches = (node, position, str) ->
  node.variable?.properties[position]?.name?.value == str

baseMatches = (node, str) ->
  node.variable?.base?.value == str

# ie. 'Ember.computed'
matchesString = (node, propString) ->
  return false unless node.variable?.properties

  [baseName, propNames...] = propString.split('.')
  baseMatches(node, baseName) and
  propNames.length == node.variable.properties.length and
  _.all propNames, (name, index) -> propMatches(node, index, name)


module.exports = { nodeType, propMatches, matchesString }
