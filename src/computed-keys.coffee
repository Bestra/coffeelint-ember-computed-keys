FindsComputedProperties = require './finds-computed-properties'

class ComputedKeys
  rule:
    name: 'ember_computed_property_dependent_keys'
    value : 'always'
    level : 'warn'
    message : 'Dependent key mismatch'
    description: 'Dependent keys should correspond to usage in CP'
    meta: ''

  lintAST : (rootAstNode, @astApi) ->
    @lintNode rootAstNode
    undefined

  lintNode: (node) ->
    cp = FindsComputedProperties.createPropertyFromNode(node)

    if cp
      cp.extraKeys.forEach (k) =>
        error = @astApi.createError
          context: "#{k.key} is not used in the CP body"
          lineNumber: k.lineNumber
          meta: "unusedKey"

        @errors.push error

      cp.missingKeys.forEach (k) =>
        error = @astApi.createError
          context: "#{k.key} doesn't have a corresponding dependent key"
          lineNumber: k.lineNumber
          meta: "needsKey"
        @errors.push error

    node.eachChild (childNode) =>
      @lintNode(childNode) if childNode

module.exports = ComputedKeys
