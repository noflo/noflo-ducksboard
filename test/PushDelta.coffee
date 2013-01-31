readenv = require "../components/PushDelta"
socket = require('noflo').internalSocket

setupComponent = ->
  c = readenv.getComponent()
  ins = socket.createSocket()
  endpoint = socket.createSocket()
  token = socket.createSocket()
  out = socket.createSocket()
  err = socket.createSocket()
  c.inPorts.in.attach ins
  c.inPorts.endpoint.attach endpoint
  c.inPorts.token.attach token
  c.outPorts.out.attach out
  c.outPorts.error.attach err
  [c, ins, endpoint, token, out, err]

exports['test without API key'] = (test) ->
  [c, ins, endpoint, token, out, err] = setupComponent()
  err.once 'data', (data) ->
    test.ok data
    test.ok data.message
    test.equal data.message, 'no API key provided'

  err.once 'disconnect', ->
    test.done()

  endpoint.send 'foo'
  ins.send 'bar'

exports['test without endpoint'] = (test) ->
  [c, ins, endpoint, token, out, err] = setupComponent()
  err.once 'data', (data) ->
    test.ok data
    test.ok data.message
    test.equal data.message, 'no endpoint provided'

  err.once 'disconnect', ->
    test.done()

  token.send 'foo'
  ins.send 'bar'

exports['test with value'] = (test) ->
  unless process.env.DUCKSBOARD_TOKEN
    test.fail null, null, 'no DUCKSBOARD_TOKEN provided'
    test.done()
    return

  unless process.env.DUCKSBOARD_ENDPOINT
    test.fail null, null, 'no DUCKSBOARD_ENDPOINT provided'
    test.done()
    return

  [c, ins, endpoint, token, out, err] = setupComponent()

  out.once 'data', (data) ->
    test.ok data
    test.ok data.response
    test.equals data.response, 'ok'
  out.once 'disconnect', ->
    test.done()

  err.once 'data', (data) ->
    test.fail null, null, data
    test.done()

  token.send process.env.DUCKSBOARD_TOKEN
  endpoint.send process.env.DUCKSBOARD_ENDPOINT
  ins.send 1
