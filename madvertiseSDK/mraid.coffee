
expandProperties = width: 320, height: 480, useCustomClose: false, isModal: false
states = ["loading", "hidden", "default", "expanded"]
placementType = "inline"
state = "loading"
viewable = false
listeners = {}

mraid =

  # public mraid API

  getVersion: -> "1.0"

  getState: -> state

  isViewable: -> viewable

  close: -> mraid_bridge.close()

  open: (url) -> mraid_bridge.open(url)

  expand: (url...) ->
    if state == "default"
      if url?.length == 0
        mraid_bridge.expand()
      else
        mraid_bridge.expand(url[0])

  getPlacementType: -> placementType

  getExpandProperties: -> expandProperties

  setExpandProperties: (properties) ->
    expandProperties.width = properties.width if properties.width
    expandProperties.height = properties.height if properties.height
    expandProperties.useCustomClose = properties.useCustomClose if properties.useCustomClose
    mraid_bridge.setExpandProperties(JSON.stringify(expandProperties))

  useCustomClose: (useCustomClose) ->
    expandProperties.useCustomClose = useCustomClose
    mraid_bridge.setExpandProperties(JSON.stringify(expandProperties))
    
  addEventListener: (event, listener) ->
    if event in ["ready", "stateChange", "viewableChange", "error"]
      (listeners[event] ||= []).push listener

  removeEventListener: (event, listener...) ->
    if listeners[event] && listener.length > 0 # remove one listener[0]
      listeners[event] = (l for l in listeners[event] when l != listener[0])
    else # remove all listeners for this event
      delete listeners[event]


  # internal functions

  fireEvent: (event) ->
    console.log "fireEvent "+event
    if listeners[event]
      for listener in listeners[event]
        if event == "ready"
          listener()
        if event == "stateChange"
          listener(state)
        if event == "viewableChange"
          listener(viewable)

  fireErrorEvent: (message, action) ->
    listener(message, action) for listener in listeners["error"]

  setState: (state_id) ->
    state = states[state_id]
    mraid.fireEvent("stateChange")

  setViewable: (is_viewable) ->
    viewable = is_viewable
    mraid.fireEvent("viewableChange")

  setPlacementType: (type) ->
    if type == 0
      placementType = "inline"
    else if type == 1
      placementType = "interstitial"

