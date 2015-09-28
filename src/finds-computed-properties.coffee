ComputedProperty = require './computed-property'
{ nodeType, propMatches, matchesString } = require './util'

isPropertyExtension = (node) ->
  nodeType(node) == "Call" and
  propMatches(node, 0, "property")

isEmberComputed = (node) ->
  matchesString(node, "Ember.computed") or
  matchesString(node, "Em.computed")

computedPropertyFromNode = (node) ->
  if node.context == "object" and
  nodeType(node) == "Assign"
    propName = node.variable.base.value

    if isEmberComputed(node.value)
      new ComputedProperty(propName, node.value)
    else if isPropertyExtension(node)
      new ComputedProperty(propName, node.value)

module.exports = { computedPropertyFromNode }
