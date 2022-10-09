import sounddevice as sd
import numpy as np
import paho.mqtt.client as mqtt
import time


#------------------#
# audio setup      #
#------------------#

SAMPLERATE = 44100
BUFFERSIZE = 512

# create an example waveform to be played
# an array to hold the a pseudo-time variable
t = np.linspace(0, np.pi * 2, BUFFERSIZE)
# two basic waveforms
s1 = np.sin(8 * t)
s2 = np.sin(6 * t)
# mix the two waveforms together
s = s1 + s2
# normalize the resulting waveform between 0 and 1
s = (s - np.min(s)) / (np.max(s) - np.min(s))
# scale down a bit to make it not too loud
s = 0.2 * s
# make sure the waveform's dtype matches the format expected by the audio stream
s = s.astype(np.float32)
s = s.reshape((-1, 1))

# initialize the global volume
# we will later set this based on the incoming MQTT messages
volume = 0.5

def play(outdata, frames, time, status):
    """The callback function that feeds the audio output stream"""
    outdata[:] = volume * s


#------------------#
# MQTT setup       #
#------------------#

# a unique client ID based on the current timestamp
client_id = "example-audio-player_{time.time()}"

def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT broker")
    client.subscribe("interact/test")

def on_message(client, userdata, message):
    try:
        val = float(message.payload)
    except:
        return

    new_volume = val / 127.0

    # test whether the sent value can be accepted
    global volume
    if 0 <= new_volume <= 0.5:  # arbitrary boundaries for demonstration
        volume = val / 127.0
    else:
        # if the value can not be accepted, send back the actual volume converted to the closest int representation
        current_volume_int = round(volume * 127)
        send_message(client, str(current_volume_int))


def send_message(client, message):
    client.publish("interact/test", message, qos=1, retain=True)


if __name__ == '__main__':
    # set up the MQTT connection
    mqtt_client = mqtt.Client(client_id=client_id)

    mqtt_client.on_connect = on_connect
    mqtt_client.on_message = on_message

    mqtt_client.connect("localhost", 1883, 60)
    mqtt_client.loop_start()

    # set up the audio output stream
    with sd.OutputStream(samplerate=SAMPLERATE, blocksize=BUFFERSIZE, channels=1, callback=play):
        # keep the stream alive until the user makes any input
        cont = input("Press Enter to stop the playback")

    # stop the MQTT event loop
    mqtt_client.loop_stop()
