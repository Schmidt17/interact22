# interact backend

The communication is based on MQTT.

## Communication protocol

### Channels

#### Commands

Sending commands (e.g. setting parameter values):

```
cmd/<context>/<target-device>/<target-device-component>/<command-type>
```

E.g.

cmd/performance/ableton-live/tempo/set

cmd/monitor-mixing/motif/level/set

Receiving command responses:

```
cmd/<context>/<target-device>/<target-device-component>/<response-type>
```

E.g.

```
cmd/performance/ableton-live/tempo/res
cmd/monitor-mixing/motif/level/res
```

#### Telemetry

Publishing/reading parameter values:

```
state/<context>/<target-device>/<target-device-component>
```

E.g.

```
state/performance/ableton-live/tempo
state/monitor-mixing/motif/level
```

### Messages

Messages are encoded as JSON strings and have the following structure:

#### Commands

```
{
	// a session ID created by the requestor, for keeping track of command status
	"sessionId": "5e89f06a-8e74-4834-a156-a01734714749",

	// the topic to respond the status of the command (error, success), referring to the sessionId
	"responseTopic" : "cmd/.../res"

	"data": {
		// the specific data of the message
	}
}
```

#### Telemetry

```
{
	// the POSIX timestamp at the moment of sending; 0 if unavailable
	"sentTimestamp": 1664727989.4076974  // unit: seconds, precision: microsecond

	// the specific data of the message
	"data": {
		// ...
	}
}
```