# interact controllers

This folder contains a collection of example controllers that implement the interact protocol.
The individual controllers are listed in the following

## web-elm

A webinterface based on the Elm language. Connection to the backend (the MQTT broker) is done
using the Eclipse Paho MQTT JavaScript client. The messages are relayed to and from the Elm app using the app's *ports*.

This example contains just a single fader and some text that allows to inspect its current state.
When the controller is not connected to the backend, or loses connection, it becomes disabled and changes color
to inform the user about the disconnect. This is useful feedback and the disabling prevents putting the 
fader in an unsynchronized state which could be misleading. The app tries to reconnect when connection was lost
and enables the interaction again once connection was successful.

Since the messages are always sent with the *retained* flag set, the fader always receives the last consensus value
upon each reconnect.