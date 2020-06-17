import ../nimopenjtalk

type
  OJTContext* = object
    mecab: Mecab
    njd: NJD
    jpcommon: JPCommon
    engine: HTS_Engine

proc initialzie*(): OJTContext =
  if Mecab_initialize(addr result.mecab) == 0:
    raise newException(Exception, "Mecab_initialize returned 0")
  NJD_initialize(addr result.njd)
  JPCommon_initialize(addr result.jpcommon)
  HTS_Engine_initialize(addr result.engine)

proc clear*(context: var OJTContext) =
  discard Mecab_clear(addr context.mecab)
  NJD_clear(addr context.njd)
  JPCommon_clear(addr context.jpcommon);
  HTS_Engine_clear(addr context.engine);

proc load*(context: var OJTContext; dn_mecab, fn_voice: string): bool =
  if Mecab_load(addr context.mecab, dn_mecab.cstring) == 0:
    return false

  var pvoice = fn_voice.cstring
  if HTS_Engine_load(addr context.engine, addr pvoice, 1) == '\0':
    return false

  if HTS_Engine_get_fullcontext_label_format(addr context.engine) != "HTS_TTS_JPN":
    return false

  return true

proc synthesis*(context: var OJTContext; txt: string): bool =
  HTS_Engine_refresh(addr context.engine)
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
        addr context.engine,
        JPCommon_get_label_feature(addr context.jpcommon),
        JPCommon_get_label_size(addr context.jpcommon).csize_t) == 1.cchar:
      result = true

proc getSamplingFrequency*(context: var OJTContext): int =
  HTS_Engine_get_sampling_frequency(addr context.engine).int

proc setSamplingFrequency*(context: var OJTContext; freq: int) =
  HTS_Engine_set_sampling_frequency(addr context.engine, freq.csize_t)

proc getNumSamples*(context: var OJTContext): int =
  HTS_Engine_get_nsamples(addr context.engine).int

proc getSpeechSample*(context: var OJTContext; index: int): int16 =
  let s = HTS_Engine_get_generated_speech(addr context.engine, index.csize_t)
  if s > 32767.0:
    result = 32767
  elif s < -32768.0:
    result = -32768
  else:
    result = int16(s)

proc writeWave*(context: var OJTContext; wavout: string) =
  var wavfp = open(wavout, fmWrite)
  HTS_Engine_save_riff(addr context.engine, wavfp)
  close(wavfp)
