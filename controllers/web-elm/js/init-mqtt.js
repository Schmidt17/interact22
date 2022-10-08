// configuration for the connection to the MQTT broker
const mqtt_host = "localhost";
const mqtt_port = 9001;
// The client name comprises a generic prefix that describes the type of client
// and a suffix that makes it unique, to allow multiple instances of the same client type to connect.
// Prefix and suffix are joined with an underscore.
const client_prefix = "web-elm";
// To generate the unique suffix, the current client time with millisecond precision is used.
// In the unlikely case that a name collision still occurs, reloading some time later will likely succeed.
const client_unique_suffix = String(moment().unix()) + String(moment().milliseconds());
const client_name = client_prefix + "_" + client_unique_suffix;

// create a MQTT client instance
const client = new Paho.MQTT.Client(mqtt_host, mqtt_port, client_name);

// variables to store actions that can be defined by the user
var connectFollowUpAction = function() {};

// set callback functions
client.onConnectionLost = onConnectionLost;
client.onMessageArrived = function (message) {};


// function to attempt to connect the client to the MQTT broker
function connectToBroker(newConnectFollowUpAction, newOnMessageArrived) {
  console.log("Trying to connect to MQTT broker at " + mqtt_host + ":" + mqtt_port + " ...");

  connectFollowUpAction = newConnectFollowUpAction;
  client.onMessageArrived = newOnMessageArrived;

  client.connect({
    onSuccess: onConnectSuccess,
    onFailure: onConnectFailure,
    useSSL: false
  });
}


// called when the client has connected
function onConnectSuccess() {
  // Once a connection has been made, subscribe to the needed channels
  console.log("Connected to MQTT broker at " + mqtt_host + ":" + mqtt_port);

  client.subscribe("interact/test", {qos: 1});
  console.log("Subscribed to topic interact/test");

  // execute the follow-up function as defined by the user
  connectFollowUpAction();
}


// called when the connection process has failed
function onConnectFailure() {
  console.log("Connecting to the MQTT broker at " + mqtt_host + ":" + mqtt_port + " has failed");
}


// called when the client loses its connection
function onConnectionLost(responseObject) {
  if (responseObject.errorCode !== 0) {
    console.log("onConnectionLost:" + responseObject.errorMessage);
  }

  console.log("Trying to reconnect ...");
  connectToBroker(connectFollowUpAction, client.onMessageArrived);
}
