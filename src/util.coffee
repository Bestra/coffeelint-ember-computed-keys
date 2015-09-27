nodeType = (node) ->
  node.constructor.name

propMatches = (node, str) ->
  node.variable?.properties[0]?.name?.value == str

module.exports = { nodeType, propMatches }
