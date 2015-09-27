_ = require 'underscore'

nameMatches = (node) ->
  node.variable?.base?.value == "Ember" || "Em"

propMatches = (node, str) ->
  node.variable?.properties[0]?.name?.value == str

isComputed = (node) ->
  nameMatches(node) && propMatches(node, "computed")

nodeType = (node) ->
  node.constructor.name

propString = (node) -> node.base.value.replace(/['"]/g,"")

isGet = (node) ->
  nodeType(node) == "Call" and
  node.variable.this == true and
  propMatches(node, "get")


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

  constructor: (@propertyName, @rootNode) ->
    [dependentKeyNodes..., fnNode] = @rootNode.args

    @dependentKeys = dependentKeyNodes.map (keyNode) ->
      key: propString(keyNode)
      lineNumber: keyNode.locationData.first_line + 1

    @propertyGets = []

    @findGets(fnNode.body)

    @extraKeys = @keyDiff(@dependentKeys, @propertyGets)
    @missingKeys = @keyDiff(@propertyGets, @dependentKeys)

    console.log "extra keys: #{@extraKeys}"
    console.log "missing keys: #{@missingKeys}"

class ComputedKeys
  rule:
    name: 'ember_computed_property_dependent_keys'
    value : 'always'
    level : 'warn'
    message : 'Dependent key mismatch'
    description: 'Dependent keys should correspond to usage in CP'

  lintAST : (node, @astApi) ->
    @lintNode node
    undefined

  lintNode: (node) ->
    if node.context == "object" && nodeType(node) == "Assign"
      if isComputed(node.value)
        cp = new ComputedProperty(node.variable.base.value, node.value)

        cp.extraKeys.forEach (k) =>
          error = @astApi.createError
            context: "#{k.key} is not used in the CP body"
            lineNumber: k.lineNumber
          @errors.push error

        cp.missingKeys.forEach (k) =>
          error = @astApi.createError
            context: "#{k.key} doesn't have a corresponding dependent key"
            lineNumber: k.lineNumber
          @errors.push error

    node.eachChild (childNode) =>
      @lintNode(childNode) if childNode

module.exports = ComputedKeys
