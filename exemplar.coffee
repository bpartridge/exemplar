# Exemplar is a utility class that allows us to define a schema
# using a series of examples.

_ = require 'underscore'

NULL_TYPE_NAME = 'null'

module.exports = class Exemplar
  constructor: (options) ->
    options ||= {}
    @disallowExtraKeys = options.disallowExtraKeys || false
    @ignoredKeys = options.ignoredKeys || []
    @allowedTypeNamesByKey = {}

  typeNameFor: (val) ->
    if not val? then return NULL_TYPE_NAME
    else if _.isArray(val)
      childTypes = _(val).map (child) -> @typeNameFor child
      childTypes = _(childTypes).uniq()

      if childTypes.length == 1 then return '[' + childTypes[0] + ']'
      else return '[*]'
    else return typeof val

  addExample: (ex) ->
    # For each key, ensure that the example's type name
    # is considered an allowed type name.
    for own key, val of ex
      if key not in @ignoredKeys
        typeName = @typeNameFor(val)
        allowedTypeNames = (@allowedTypeNamesByKey[key] ||= [])
        if typeName not in allowedTypeNames
          allowedTypeNames.push(typeName)

    # For any type names seen in previous examples,
    # if they weren't seen in this example,
    # add NULL_TYPE_NAME as an allowed type name 
    # to show that this key is optional.
    for key, allowedTypeNames of @allowedTypeNamesByKey
      if not ex[key]?
        if NULL_TYPE_NAME not in allowedTypeNames
          allowedTypeNames.push(NULL_TYPE_NAME)

  check: (o) ->
    if typeof o != 'object' then return false
    for own key, val of o
      if key not in @ignoredKeys
        typeName = @typeNameFor(val)
        allowedTypeNames = @allowedTypeNamesByKey[key]
        if allowedTypeNames?
          if typeName not in allowedTypeNames then return false
        else
          if @disallowExtraKeys then return false 
    return true
