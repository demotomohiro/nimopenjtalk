import nimopenjtalk/nimojtutil

proc main =
  var context = initialzie()
  defer:
    context.clear()
  if not context.load("../data/open_jtalk_dic_utf_8-1.11", "../data/mei/mei_normal.htsvoice"):
    echo "Failed to load"
    return

  if context.synthesis("みなさんこんにちは。ニム言語からOpen J talkを使ってこの音声は合成されました。よろしくお願いします。"):
    context.writeWave("test.wav")
  else:
    echo "Error: waveform cannot be synthesized."

main()
