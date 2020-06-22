import nimopenjtalk/nimojtutil

proc main =
  var
    context = createContext()
    voice = createVoice()
  defer:
    voice.clear()
    context.clear()

  if not context.load("../data/open_jtalk_dic_utf_8-1.11"):
    echo "Failed to load dictionary"
    return

  if not voice.load("../data/mei/mei_normal.htsvoice"):
    echo "Failed to load voice"
    return

  if context.synthesis(voice, "みなさんこんにちは。ニム言語からOpen J talkを使ってこの音声は合成されました。よろしくお願いします。"):
    voice.writeWave("test.wav")
  else:
    echo "Error: waveform cannot be synthesized."

main()
