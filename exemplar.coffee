# Exemplar is a utility class that allows us to define a schema
# using a series of examples.

NULL_TYPE_NAME = 'null'

isArray = Array.isArray || (obj) -> (obj?.toString()) == '[object Array]'

class Exemplar
  constructor: (options) ->
    options ||= {}
    @disallowExtraKeys = options.disallowExtraKeys || false
    @ignoredKeys = options.ignoredKeys || []
    @allowedTypeNamesByKey = {}

  typeNameFor: (val) ->
    if not val? then return NULL_TYPE_NAME
    else if isArray(val)
      childTypes = ((@typeNameFor child) for child in val)
      if childTypes.length == 0
        return '[*]'
      else
        # If there's any mismatch, return a wildcard (heterogeneous) array
        for childType in childTypes
          if childType != childTypes[0]
            return '[*]'

        # Otherwise, return a homogeneous array
        return '[' + childTypes[0] + ']'
    # TODO: handle nested objects
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

if module?
  module.exports = Exemplar
  Exemplar.Exemplar = Exemplar # so you can use require('exemplar').Exemplar
else if window?
  window.Exemplar = Exemplar
