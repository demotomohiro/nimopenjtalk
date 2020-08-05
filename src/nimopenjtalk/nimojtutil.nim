import ../nimopenjtalk

type
  OJTContext* = object
    mecab: Mecab
    njd: NJD
    jpcommon: JPCommon

  OJTVoice* = object
    engine: HTS_Engine

proc createContext*(): OJTContext =
  if Mecab_initialize(addr result.mecab) == 0:
    raise newException(Exception, "Mecab_initialize returned 0")
  NJD_initialize(addr result.njd)
  JPCommon_initialize(addr result.jpcommon)

proc clear*(context: var OJTContext) =
  discard Mecab_clear(addr context.mecab)
  NJD_clear(addr context.njd)
  JPCommon_clear(addr context.jpcommon);

proc load*(context: var OJTContext; dn_mecab: string): bool =
  Mecab_load(addr context.mecab, dn_mecab.cstring) != 0

proc createVoice*(): OJTVoice =
  HTS_Engine_initialize(addr result.engine)

proc clear*(voice: var OJTVoice) =
  HTS_Engine_clear(addr voice.engine);

proc load*(voice: var OJTVoice; fn_voice: string): bool =
  var pvoice = fn_voice.cstring
  if HTS_Engine_load(addr voice.engine, addr pvoice, 1) == '\0':
    return false

  if HTS_Engine_get_fullcontext_label_format(addr voice.engine) != "HTS_TTS_JPN":
    return false

  return true

proc synthesis*(context: var OJTContext; voice: var OJTVoice; txt: string): bool =
  HTS_Engine_refresh(addr voice.engine)
  JPCommon_refresh(addr context.jpcommon)
  NJD_refresh(addr context.njd)
  discard Mecab_refresh(addr context.mecab)

  assert txt.len != 0
  var buf = newString(txt.len)
  text2mecab(addr buf[0], txt.cstring)
  if Mecab_analysis(addr context.mecab, addr buf[0]) == 0:
    raise newException(Exception, "Mecab_analysis returned 0")
  mecab2njd(addr context.njd, Mecab_get_feature(addr context.mecab), Mecab_get_size(addr context.mecab))
  njd_set_pronunciation(addr context.njd)
  njd_set_digit(addr context.njd)
  njd_set_accent_phrase(addr context.njd)
  njd_set_accent_type(addr context.njd)
  njd_set_unvoiced_vowel(addr context.njd)
  njd_set_long_vowel(addr context.njd)
  njd2jpcommon(addr context.jpcommon, addr context.njd)
  JPCommon_make_label(addr context.jpcommon)
  if JPCommon_get_label_size(addr context.jpcommon) > 2:
    if HTS_Engine_synthesize_from_strings(
        addr voice.engine,
        JPCommon_get_label_feature(addr context.jpcommon),
        JPCommon_get_label_size(addr context.jpcommon).csize_t) == 1.cchar:
      result = true

proc samplingFrequency*(voice: var OJTVoice): int =
  HTS_Engine_get_sampling_frequency(addr voice.engine).int

proc `samplingFrequency=`*(voice: var OJTVoice; freq: int) =
  HTS_Engine_set_sampling_frequency(addr voice.engine, freq.csize_t)

proc numSamples*(voice: var OJTVoice): int =
  HTS_Engine_get_nsamples(addr voice.engine).int

proc getSpeechSample*(voice: var OJTVoice; index: int): int16 =
  let s = HTS_Engine_get_generated_speech(addr voice.engine, index.csize_t)
  if s > 32767.0:
    result = 32767
  elif s < -32768.0:
    result = -32768
  else:
    result = int16(s)

proc writeWave*(voice: var OJTVoice; wavout: string) =
  var wavfp = open(wavout, fmWrite)
  HTS_Engine_save_riff(addr voice.engine, wavfp)
  close(wavfp)

proc volume*(voice: var OJTVoice): float =
  HTS_Engine_get_volume(addr voice.engine)

proc `volume=`*(voice: var OJTVoice; volume: float) =
  HTS_Engine_set_volume(addr voice.engine, volume)

proc speed*(voice: var OJTVoice): float =
  HTS_Engine_get_speed(addr voice.engine)

proc `speed=`*(voice: var OJTVoice; speed: float) =
  HTS_Engine_set_speed(addr voice.engine, speed)

# 声質? 別名all-pass constant [0.0, 1.0]
proc alpha*(voice: var OJTVoice): float =
  HTS_Engine_get_alpha(addr voice.engine)

proc `alpha=`*(voice: var OJTVoice; alpha: float) =
  HTS_Engine_set_alpha(addr voice.engine, alpha)

# 声の高さ
proc addHalfTone*(voice: var OJTVoice): float =
  HTS_Engine_get_add_half_tone(addr voice.engine)

proc `addHalfTone=`*(voice: var OJTVoice; add_half_tone: float) =
  HTS_Engine_add_half_tone(addr voice.engine, add_half_tone)
