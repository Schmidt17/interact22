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

// create a client instance
const client = new Paho.MQTT.Client(mqtt_host, mqtt_port, client_name);

// set callback functions
client.onConnectionLost = onConnectionLost;
client.onMessageArrived = onMessageArrived;

// connect the client
function connect() {
  console.log("Trying to connect to MQTT broker at " + mqtt_host + ":" + mqtt_port + " ...");

  client.connect({
    onSuccess: onConnectSuccess,  // onConnectSuccess is called when the connection is established
    useSSL: false
  });
}

connect();

// called when the client connects
function onConnectSuccess() {
  // Once a connection has been made, subscribe to the needed channels
  console.log("Connected to MQTT broker at " + mqtt_host + ":" + mqtt_port);

  client.subscribe("interact/test", {qos: 1});
  console.log("Subscribed to topic interact/test");

  // attach the sending function to the respective port of the elm app
  app.ports.sendMQTTMessage.subscribe(function(message) {
    var mqttMessage = new Paho.MQTT.Message(message);

    mqttMessage.destinationName = "interact/test";
    mqttMessage.qos = 1;
    mqttMessage.retained = true;

    client.send(mqttMessage); 
  })
}

// called when the client loses its connection
function onConnectionLost(responseObject) {
  if (responseObject.errorCode !== 0) {
    console.log("onConnectionLost:" + responseObject.errorMessage);
  }

  console.log("Trying to reconnect ...");
  connect();
}

// called when a message arrives
function onMessageArrived(message) {
  const msg_string = message.payloadString;
  // msg_dict = JSON.parse(message.payloadString);
  // // console.log(msg_dict);

  // if (message.destinationName == 'astridtest/valves') {
  //   handleActuatorMessage(msg_dict);
  // } else if (message.destinationName == 'astridtest/sensors') {
  //   handleSensorMessage(msg_dict);
  // }

  app.ports.receiveMQTTMessage.send(message.payloadString);
}