import nimopenjtalk/nimojtutil, openal, strutils, os

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

proc playSpeech(context: var OJTContext; text: string; src: var OpenALSrc) =
  if context.synthesis(text):
    let
      freq = context.getSamplingFrequency
      numSamples = context.getNumSamples
    if numSamples == 0:
      echo "No samples"
      return
    var samples = newSeqUninitialized[int16](numSamples)
    for i in 0..<numSamples:
      samples[i] = context.getSpeechSample(i)
    alSourceStop(src.source)
    alSourcei(src.source, AL_BUFFER, 0)
    alBufferData(src.buffer, AL_FORMAT_MONO16, addr samples[0], (sizeof(samples[0]) * numSamples).ALsizei, freq.ALsizei)
    alSourcei(src.source, AL_BUFFER, src.buffer.ALint)
    alSourcePlay(src.source)
  else:
    quit "Failed to synthesis speech"

proc main =
  var
    context = initialzie()
    alContext = initOpenAL()
    alSrc = initOpenALSrc()
  defer:
    alSrc.delete()
    alcontext.close()
    context.clear()

  if not context.load("../data/open_jtalk_dic_utf_8-1.11", "../data/mei/mei_normal.htsvoice"):
    echo "Failed to load"
    return

  echo "Type text to speech:"
  for l in stdin.lines:
    context.playSpeech(l, alSrc)

  context.playSpeech("さようなら", alSrc)
  sleep(1500)

main()
