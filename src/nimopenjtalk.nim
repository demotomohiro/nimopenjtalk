import os

const
  parentDir = currentSourcePath.parentDir()
  htsDir = parentDir / "nimopenjtalk/private/hts_engine_API"
  openjtalkDir = parentDir / "nimopenjtalk/private/open_jtalk"

{.passC: "-I " & (htsDir / "include") & " -D AUDIO_PLAY_NONE",
  compile: htsDir / "lib/HTS_audio.c",
  compile: htsDir / "lib/HTS_engine.c",
  compile: htsDir / "lib/HTS_gstream.c",
  compile: htsDir / "lib/HTS_label.c",
  compile: htsDir / "lib/HTS_misc.c",
  compile: htsDir / "lib/HTS_model.c",
  compile: htsDir / "lib/HTS_pstream.c",
  compile: htsDir / "lib/HTS_sstream.c",
  compile: htsDir / "lib/HTS_vocoder.c".}

{.passC: "-D CHARSET_UTF_8",
  compile: openjtalkDir / "text2mecab/text2mecab.c".}

when defined(windows):
  {.passC: "-D HAVE_WINDOWS_H".}
else:
  {.passC: "-D HAVE_STDINT_H -D HAVE_SYS_STAT_H -D HAVE_FCNTL_H -D HAVE_SYS_MMAN_H -D HAVE_UNISTD_H -D HAVE_DIRENT_H".}

{.passC: "-D DIC_VERSION=102 -D PACKAGE=\\\"open_jtalk\\\" -D VERSION=\\\"1.01\\\"".}
{.compile: openjtalkDir / "mecab/src/char_property.cpp",
  compile: openjtalkDir / "mecab/src/connector.cpp",
  compile: openjtalkDir / "mecab/src/context_id.cpp",
  compile: openjtalkDir / "mecab/src/dictionary.cpp",
  compile: openjtalkDir / "mecab/src/dictionary_compiler.cpp",
  compile: openjtalkDir / "mecab/src/dictionary_generator.cpp",
  compile: openjtalkDir / "mecab/src/dictionary_rewriter.cpp",
  compile: openjtalkDir / "mecab/src/eval.cpp",
  compile: openjtalkDir / "mecab/src/feature_index.cpp",
  compile: openjtalkDir / "mecab/src/iconv_utils.cpp",
  compile: openjtalkDir / "mecab/src/lbfgs.cpp",
  compile: openjtalkDir / "mecab/src/learner.cpp",
  compile: openjtalkDir / "mecab/src/learner_tagger.cpp",
  compile: openjtalkDir / "mecab/src/libmecab.cpp",
  compile: openjtalkDir / "mecab/src/mecab.cpp",
  compile: openjtalkDir / "mecab/src/nbest_generator.cpp",
  compile: openjtalkDir / "mecab/src/param.cpp",
  compile: openjtalkDir / "mecab/src/string_buffer.cpp",
  compile: openjtalkDir / "mecab/src/tagger.cpp",
  compile: openjtalkDir / "mecab/src/tokenizer.cpp",
  compile: openjtalkDir / "mecab/src/utils.cpp",
  compile: openjtalkDir / "mecab/src/viterbi.cpp",
  compile: openjtalkDir / "mecab/src/writer.cpp".}

{.passC: "-I " & (openjtalkDir / "njd"),
  compile: openjtalkDir / "mecab2njd/mecab2njd.c".}

{.compile: openjtalkDir / "njd/njd.c",
  compile: openjtalkDir / "njd/njd_node.c".}

{.compile: openjtalkDir / "njd_set_pronunciation/njd_set_pronunciation.c".}
{.compile: openjtalkDir / "njd_set_digit/njd_set_digit.c".}
{.compile: openjtalkDir / "njd_set_accent_phrase/njd_set_accent_phrase.c".}
{.compile: openjtalkDir / "njd_set_accent_type/njd_set_accent_type.c".}
{.compile: openjtalkDir / "njd_set_unvoiced_vowel/njd_set_unvoiced_vowel.c".}
{.compile: openjtalkDir / "njd_set_long_vowel/njd_set_long_vowel.c".}
{.passC: "-I " & (openjtalkDir / "jpcommon"),
  compile: openjtalkDir / "njd2jpcommon/njd2jpcommon.c".}
{.compile: openjtalkDir / "jpcommon/jpcommon.c",
  compile: openjtalkDir / "jpcommon/jpcommon_label.c",
  compile: openjtalkDir / "jpcommon/jpcommon_node.c".}

type
  Mecab* {.header: openjtalkDir / "mecab/src/mecab.h".} = object
  NJD* {.header: openjtalkDir / "njd/njd.h".} = object
  JPCommon* {.header: openjtalkDir / "jpcommon/jpcommon.h".} = object
  HTS_Engine* {.header: htsDir / "include/HTS_engine.h".} = object
  HTS_Boolean = cchar

{.push header: openjtalkDir / "mecab/src/mecab.h"}
proc Mecab_initialize*(m: ptr Mecab): cint
proc Mecab_load*(m: ptr Mecab; dicdir: cstring): cint
proc Mecab_analysis*(m: ptr Mecab; str: cstring): cint
proc Mecab_get_size*(m: ptr Mecab): cint
proc Mecab_get_feature*(m: ptr Mecab): ptr cstring
proc Mecab_refresh*(m: ptr Mecab): int
proc Mecab_clear*(m: ptr Mecab): int
{.pop.}

{.push header: openjtalkDir / "njd/njd.h"}
proc NJD_initialize*(njd: ptr NJD)
proc NJD_refresh*(njd: ptr NJD)
proc NJD_clear*(wl: ptr NJD)
{.pop.}

{.push header: openjtalkDir / "jpcommon/jpcommon.h"}
proc JPCommon_initialize*(jpcommon: ptr JPCommon)
proc JPCommon_make_label*(jpcommon: ptr JPCommon)
proc JPCommon_get_label_size*(jpcommon: ptr JPCommon): cint
proc JPCommon_get_label_feature*(jpcommon: ptr JPCommon): ptr cstring
proc JPCommon_refresh*(jpcommon: ptr JPCommon)
proc JPCommon_clear*(jpcommon: ptr JPCommon)
{.pop.}

{.push header: htsDir / "include/HTS_engine.h"}
proc HTS_Engine_initialize*(engine: ptr HTS_Engine)
proc HTS_Engine_load*(engine: ptr HTS_Engine; voices: ptr cstring; num_voices: csize_t): HTS_Boolean
proc HTS_Engine_get_fullcontext_label_format*(engine: ptr HTS_Engine): cstring
proc HTS_Engine_synthesize_from_strings*(engine: ptr HTS_Engine; lines: ptr cstring; num_lines: csize_t): HTS_Boolean
proc HTS_Engine_save_riff*(engine: ptr HTS_Engine; fp: File)
proc HTS_Engine_refresh*(engine: ptr HTS_Engine)
proc HTS_Engine_clear*(engine: ptr HTS_Engine)
proc HTS_Engine_get_sampling_frequency*(engine: ptr HTS_Engine): csize_t
proc HTS_Engine_get_nsamples*(engine: ptr HTS_Engine): csize_t
proc HTS_Engine_get_generated_speech*(engine: ptr HTS_Engine; index: csize_t): cdouble
proc HTS_Engine_set_sampling_frequency*(engine: ptr HTS_Engine; i: csize_t)
proc HTS_Engine_set_volume*(engine: ptr HTS_Engine; f: cdouble)
proc HTS_Engine_get_volume*(engine: ptr HTS_Engine;): cdouble
proc HTS_Engine_set_speed*(engine: ptr HTS_Engine; f: cdouble)
proc HTS_Engine_get_speed*(engine: ptr HTS_Engine): cdouble
proc HTS_Engine_set_alpha*(engine: ptr HTS_Engine; f: cdouble)
proc HTS_Engine_get_alpha*(engine: ptr HTS_Engine): cdouble
proc HTS_Engine_add_half_tone*(engine: ptr HTS_Engine; f: cdouble)
proc HTS_Engine_get_add_half_tone*(engine: ptr HTS_Engine): cdouble
{.pop.}

proc text2mecab*(output, input: cstring) {.header: openjtalkDir / "text2mecab/text2mecab.h".}
proc mecab2njd*(njd: ptr NJD; feature: ptr cstring; size: cint) {.header: openjtalkDir / "mecab2njd/mecab2njd.h".}
proc njd_set_pronunciation*(njd: ptr NJD) {.header: openjtalkDir / "njd_set_pronunciation/njd_set_pronunciation.h".}
proc njd_set_digit*(njd: ptr NJD) {.header: openjtalkDir / "njd_set_digit/njd_set_digit.h".}
proc njd_set_accent_phrase*(njd: ptr NJD) {.header: openjtalkDir / "njd_set_accent_phrase/njd_set_accent_phrase.h".}
proc njd_set_accent_type*(njd: ptr NJD) {.header: openjtalkDir / "njd_set_accent_type/njd_set_accent_type.h".}
proc njd_set_unvoiced_vowel*(njd: ptr NJD) {.header: openjtalkDir / "njd_set_unvoiced_vowel/njd_set_unvoiced_vowel.h".}
proc njd_set_long_vowel*(njd: ptr NJD) {.header: openjtalkDir / "njd_set_long_vowel/njd_set_long_vowel.h".}
proc njd2jpcommon*(jpcommon: ptr JPCommon; njd: ptr NJD) {.header: openjtalkDir / "njd2jpcommon/njd2jpcommon.h".}
