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

    propNode = node.value

    if isEmberComputed(propNode)
      [argNodes..., fnNode] = propNode.args
      new ComputedProperty(propName, argNodes, fnNode)
    else if isPropertyExtension(propNode)
      new ComputedProperty(propName, propNode.args, propNode.variable.base)

module.exports = { computedPropertyFromNode }
