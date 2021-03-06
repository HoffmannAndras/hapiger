describe 'events routes', ->
  describe 'POST events', ->
    it 'should work', ->
      ns = random_namespace()
      start_server
      .then(->
        client.create_namespace(ns)
      )
      .then(->
        client.create_events([{namespace: ns, person: 'p', action: 'a', thing: 't1'}])
      )
      .spread((body, resp) ->
        body.events[0].person.should.equal 'p'
      )

    it 'should 404 on bad namespace', ->
      ns = random_namespace()
      start_server
      .then(->
        client.create_events([{namespace: ns, person: 'p', action: 'a', thing: 't1'}])
      )
      .then(->
        throw "SHOULD NOT GET HERE"
      )
      .catch(GERClient.Not200Error, (e) ->
        e.status.should.equal 404
      )

  describe 'GET events', ->
    it 'should recall events', ->
      ns = random_namespace()
      start_server
      .then(->
        client.create_namespace(ns)
      )
      .then(->
        client.create_events([{namespace: ns, person: 'p', action: 'a', thing: 't1'}])
      )
      .spread((body, resp) ->
        client.show_events(ns, 'p')
      )
      .spread((body, resp) ->
        body.events[0].person.should.equal 'p'
      )


  describe 'DELETE events', ->
    it 'should remove event', ->
      ns = random_namespace()
      start_server
      .then(->
        client.create_namespace(ns)
      )
      .then(->
        client.create_events([{namespace: ns, person: 'p', action: 'a', thing: 't1'}])
        client.create_events([{namespace: ns, person: 'p', action: 'a', thing: 't2'}])
        client.create_events([{namespace: ns, person: 'p', action: 'a', thing: 't3'}])
      )
      .then(->
        client.delete_events(ns, {thing: 't1'})
        client.delete_events(ns, {thing: 't2'})
      )
      .spread((body, resp) ->
        client.show_events(ns, 'p')
      )
      .catch(GERClient.Not200Error, (e) ->
        e.status.should.equal 404
      )
