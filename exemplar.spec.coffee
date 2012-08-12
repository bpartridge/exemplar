
Exemplar = require './exemplar'

describe 'exemplar', ->

  e = undefined

  beforeEach ->
    e = new Exemplar
    @addMatchers
      toAccept: (o) ->
        return @actual.check(o)

  it 'by default, should consider anything valid without an example', ->
    expect(e).toAccept({foo:'bar'})

  it 'should accept a simple type', ->
    e.addExample {foo:1}
    expect(e).toAccept({foo:2})
    expect(e).not.toAccept({foo:'bar'})

  it 'should accept an array type by its member types', ->
    e.addExample {foo:['bar','baz']}
    expect(e).toAccept({foo:['hi','bye']})
    expect(e).not.toAccept({foo:[1,2]})

  it 'should accept all nested object types as equal', ->
    e.addExample {foo:{boo:'bar'}}
    expect(e).toAccept({foo:{boo:'baz'}})
    expect(e).toAccept({foo:{boo:3}})
