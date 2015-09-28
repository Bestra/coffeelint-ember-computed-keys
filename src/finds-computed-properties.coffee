ComputedProperty = require './computed-property'
{ nodeType, matchesString } = require './util'

isComputed = (node) ->
  matchesString(node, "Ember.computed") || matchesString(node, "Em.computed")

createPropertyFromNode = (node) ->
  if node.context == "object" and
  nodeType(node) == "Assign" and
  isComputed(node.value)

    new ComputedProperty(node.variable.base.value, node.value)

module.exports = { createPropertyFromNode }
