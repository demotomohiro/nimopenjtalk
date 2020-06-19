# nimopenjtalk
nimopenjtalk is [Open JTalk](http://open-jtalk.sourceforge.net/) and [hts_engine API](http://hts-engine.sourceforge.net/) bindings for Nim.
Open JTalk is a Japanese text-to-speech system.
The hts_engine is software to synthesize speech waveform from HMMs trained by the HMM-based speech synthesis system (HTS).

## How to run example code
Open JTalk uses dictionary files and HTS voice file.

You can download the dictionary for Open JTalk version 1.11 Binary Package (UTF-8) from http://open-jtalk.sourceforge.net/

You can get HTS voice file from MMDAgent Contents package file that you can download from http://www.mmdagent.jp/ .
There are `*.htsvoice` files in `Voice` directory after unzip MMDAgent_Example-1.8.mmda.

For example:
```console
$ ls
MDAgent_Example-1.8.mmda
open_jtalk_dic_utf_8-1.11.tar.gz
$ git clone https://github.com/demotomohiro/nimopenjtalk.git
$ mkdir nimopenjtalk/data
$ unzip MMDAgent_Example-1.8.mmda
$ cp -r MMDAgent_Example-1.8/Voice/mei nimopenjtalk/data
$ tar x -C nimopenjtalk/data -f open_jtalk_dic_utf_8-1.11.tar.gz
$ cd nimopenjtalk/examples
$ nim cpp -r --path:../src speechSynthWave.nim
$ ffplay test.wav
```
