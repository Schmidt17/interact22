import pyaudio
import numpy as np
import paho.mqtt.client as mqtt
import time


#------------------#
# pyaudio setup    #
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
# make sure the waveform's dtype matches the format expected by the pyaudio stream
s = s.astype(np.float32)

# initialize the global volume
# we will later set this based on the incoming MQTT messages
volume = 1.0

def play(in_data, frame_count, time_info, status):
	"""The callback function that feeds the audio output stream"""
	return volume * s, pyaudio.paContinue


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

	global volume
	volume = val / 127.0


if __name__ == '__main__':
	# set up the MQTT connection
	mqtt_client = mqtt.Client(client_id=client_id)

	mqtt_client.on_connect = on_connect
	mqtt_client.on_message = on_message

	mqtt_client.connect("localhost", 1883, 60)
	mqtt_client.loop_start()

	# set up the audio output stream
	pa = pyaudio.PyAudio()

	stream = pa.open(format=pyaudio.paFloat32,          # it is very important to always feed samples in the format specified here to this stream, can otherwise lead to distorted sound
                     channels=1,                        # mono
                     rate=SAMPLERATE,
                     output=True,
                     frames_per_buffer=BUFFERSIZE,
                     start=False, 						# don't start streaming yet
                     stream_callback=play)              # whenever the buffer is ready for new samples, it will call this function to obtain the next chunk

	# start the audio output stream
	stream.start_stream()

	# keep the stream alive until the user makes any input
	cont = input("Press Enter to stop the playback")

	# stop the audio output stream
	stream.stop_stream()
	stream.close()

	# close PyAudio
	pa.terminate()

	# stop the MQTT event loop
	mqtt_client.loop_stop()
