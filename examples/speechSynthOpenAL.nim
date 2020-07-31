import nimopenjtalk/nimojtutil, openal, strutils, os, strformat

type
  OpenALContext = object
    dev: ALCdevice
    context: ALCcontext

  OpenALSrc = object
    buffer: ALuint
    source: ALuint

proc alCheckErr() =
  let err = alGetError()
  if err != AL_NO_ERROR.ALenum:
    echo "AL error code: ", err.toHex
    doAssert err == AL_NO_ERROR.ALenum

proc initOpenAL(): OpenALContext =
  result.dev = alcOpenDevice(nil)
  doAssert result.dev != nil
  result.context = alcCreateContext(result.dev, nil)
  doAssert result.context != nil
  doAssert alcMakeContextCurrent(result.context)
  discard alGetError()
 
proc close(x: var OpenALContext) =
  discard alcMakeContextCurrent(nil)
  alcDestroyContext(x.context)
  discard alcCloseDevice(x.dev)

proc initOpenALSrc(): OpenALSrc =
  alGenBuffers(1, addr result.buffer)
  alGenSources(1, addr result.source)
  alCheckErr()

proc delete(x: var OpenALSrc) =
  alSourceStop(x.source)
  alDeleteSources(1, addr x.source)
  alDeleteBuffers(1, addr x.buffer)

proc playSpeech(context: var OJTContext; voice: var OJTVoice; text: string; src: var OpenALSrc) =
  if context.synthesis(voice, text):
    let
      freq = voice.samplingFrequency
      numSamples = voice.numSamples
    if numSamples == 0:
      echo "No samples"
      return
    var samples = newSeqUninitialized[int16](numSamples)
    for i in 0..<numSamples:
      samples[i] = voice.getSpeechSample(i)
    alSourceStop(src.source)
    alSourcei(src.source, AL_BUFFER, 0)
    alBufferData(src.buffer, AL_FORMAT_MONO16, addr samples[0], (sizeof(samples[0]) * numSamples).ALsizei, freq.ALsizei)
    alSourcei(src.source, AL_BUFFER, src.buffer.ALint)
    alSourcePlay(src.source)
  else:
    quit "Failed to synthesis speech"

proc runCmd(cmd: string;
            context: var OJTContext;
            voice: var OJTVoice;
            src: var OpenALSrc) =
  let tokens = cmd.splitWhitespace
  doAssert tokens.len > 0
  case tokens[0]
  of "vol":
    var vol = voice.volume
    if tokens.len > 1:
      let delta = parseFloat(tokens[1])
      vol += delta
      voice.volume = vol
    echo fmt"{vol:g}"
    let
      prefix = if vol < 0.0: "まいなす" else: ""
      speech = fmt"音量は{prefix}{vol.abs:g}です。"
    context.playSpeech(voice, speech, src)
  else:
    context.playSpeech(voice, fmt"おまえは何をいっているんだ？", src)

proc main =
  var
    context = createContext()
    alContext = initOpenAL()
    alSrc = initOpenALSrc()
  defer:
    alSrc.delete()
    alcontext.close()
    context.clear()

  if not context.load("../data/open_jtalk_dic_utf_8-1.11"):
    echo "Failed to load dictionary"
    return

  var
    voiceHappy = createVoice()
    voiceNormal = createVoice()
    voiceAngry = createVoice()
    voiceSad = createVoice()
  defer:
    voiceSad.clear()
    voiceAngry.clear()
    voiceNormal.clear()
    voiceHappy.clear()

  if not voiceHappy.load("../data/mei/mei_happy.htsvoice"):
    echo "Failed to load voice"
    return

  if not voiceNormal.load("../data/mei/mei_normal.htsvoice"):
    echo "Failed to load voice"
    return

  if not voiceAngry.load("../data/mei/mei_angry.htsvoice"):
    echo "Failed to load voice"
    return

  if not voiceSad.load("../data/mei/mei_sad.htsvoice"):
    echo "Failed to load voice"
    return

  context.playSpeech(voiceHappy, "いらっしゃいませ", alSrc)
  echo "Type text to speech:"
  for l in stdin.lines:
    if l.len == 0:
      context.playSpeech(voiceAngry, "何か書いてよ", alSrc)
    elif l[0] == ' ' or l[0] == '\t':
      runCmd(l, context, voiceNormal, alSrc)
    else:
      context.playSpeech(voiceNormal, l, alSrc)

  context.playSpeech(voiceSad, "さようなら", alSrc)
  sleep(1500)

main()
