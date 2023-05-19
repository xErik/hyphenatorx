import 'dart:math' as Math show min, max;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/language_en_us.dart';
import 'package:hyphenatorx/languages/languageconfig.dart';
import 'package:hyphenatorx/token/wrapresult.dart';

final text =
    '''The arts are a vast subdivision of culture, composed of many creative endeavors and disciplines. It is a broader term than "art", which as a description of a field usually means only the visual arts. The arts encompass the visual arts, the literary arts and the performing arts – music, theatre, dance and film, among others. This list is by no means comprehensive, but only meant to introduce the concept of the arts. For all intents and purposes, the history of the arts begins with the history of art. The arts might have origins in early human evolutionary prehistory. According to a recent suggestion, several forms of audio and visual arts (rhythmic singing and drumming on external objects, dancing, body and face painting) were developed very early in hominid evolution by the forces of natural selection in order to reach an altered state of consciousness. In this state, which Jordania calls battle trance, hominids and early human were losing their individuality, and were acquiring a new collective identity, where they were not feeling fear or pain, and were religiously dedicated to the group interests, in total disregards of their individual safety and life. This state was needed to defend early hominids from predators, and also to help to obtain food by aggressive scavenging. Ritualistic actions involving heavy rhythmic music, rhythmic drill, coupled sometimes with dance and body painting had been universally used in traditional cultures before the hunting or military sessions in order to put them in a specific altered state of consciousness and raise the morale of participants.''';
final expectedText =
    '''The arts are a vast sub-di-vi-sion of cul-ture, com-posed of many cre-ative endeav-ors and dis-ci-plines. It is a broader term than "art", which as a descrip-tion of a field usu-ally means only the visual arts. The arts encom-pass the visual arts, the lit-er-ary arts and the per-form-ing arts – music, the-atre, dance and film, among others. This list is by no means com-pre-hen-sive, but only meant to intro-duce the con-cept of the arts. For all intents and pur-poses, the his-tory of the arts begins with the his-tory of art. The arts might have ori-gins in early human evo-lu-tion-ary pre-his-tory. Accord-ing to a recent sugges-tion, sev-eral forms of audio and visual arts (rhyth-mic sing-ing and drum-ming on exter-nal objects, danc-ing, body and face paint-ing) were devel-oped very early in hominid evo-lu-tion by the forces of nat-ural selec-tion in order to reach an altered state of con-scious-ness. In this state, which Jor-da-nia calls bat-tle trance, hominids and early human were los-ing their indi-vid-u-al-ity, and were acquir-ing a new col-lec-tive iden-tity, where they were not feel-ing fear or pain, and were reli-giously ded-i-cated to the group inter-ests, in total dis-re-gards of their indi-vid-ual safety and life. This state was needed to defend early hominids from preda-tors, and also to help to obtain food by aggres-sive scaveng-ing. Rit-u-al-is-tic actions involv-ing heavy rhyth-mic music, rhyth-mic drill, cou-pled some-times with dance and body paint-ing had been uni-ver-sally used in tra-di-tional cul-tures before the hunt-ing or mil-i-tary ses-sions in order to put them in a spe-cific altered state of con-scious-ness and raise the morale of par-tic-i-pants.''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final LanguageConfig config = Language_en_us();
  late TextStyle sRoboto;

  setUpAll(() async {
    final Future<ByteData> data = rootBundle.load('test/Roboto-Regular.ttf');
    final FontLoader fontLoader = FontLoader('roboto')..addFont(data);
    await fontLoader.load();

    sRoboto = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
      height: 1.17,
    );
  });

  // -------------------------------------------------------------------
  // General tests
  // -------------------------------------------------------------------

  test('soft-hyphen', () async {
    final hyphend = Hyphenator(config).hyphenateWord('subdivision');
    expect(hyphend.contains('\u{00AD}'), true);
  });

  test('abbreviations', () async {
    final abbr = await Hyphenator.languageAbbr();
    expect(abbr.contains('en_us'), true);
  });

  test('exceptions', () {
    final hyphenator = Hyphenator(config, symbol: '_');
    expect(hyphenator.hyphenateText('philanthropic'), 'phil_an_thropic');
  });

  // -------------------------------------------------------------------
  // load()
  // -------------------------------------------------------------------

  test('loadAsync', () async {
    final hyphenator =
        await Hyphenator.loadAsync(Language.language_en_us, symbol: '_');
    expect(hyphenator.hyphenateText('subdivision'), 'sub_di_vi_sion');
    expect(hyphenator.hyphenateText('creative'), 'cre_ative');
    expect(hyphenator.hyphenateText('disciplines'), 'dis_ci_plines');
  });

  test('loadAsyncByAbbr', () async {
    final hyphenator = await Hyphenator.loadAsyncByAbbr('en_us', symbol: '_');
    expect(hyphenator.hyphenateText('subdivision'), 'sub_di_vi_sion');
    expect(hyphenator.hyphenateText('creative'), 'cre_ative');
    expect(hyphenator.hyphenateText('disciplines'), 'dis_ci_plines');
  });

  // -------------------------------------------------------------------
  // hyphenateText()
  // -------------------------------------------------------------------

  test('hyphenate-text', () {
    final hyphenator = Hyphenator(config, symbol: '_');
    expect(hyphenator.hyphenateText('subdivision'), 'sub_di_vi_sion');
    expect(hyphenator.hyphenateText('creative'), 'cre_ative');
    expect(hyphenator.hyphenateText('disciplines'), 'dis_ci_plines');
  });

  // -------------------------------------------------------------------
  // hyphenateWord()
  // -------------------------------------------------------------------

  test('hyphenate-word', () {
    final hyphenator = Hyphenator(
      config,
      symbol: '_',
    );

    expect(hyphenator.hyphenateWord('subdivision'), 'sub_di_vi_sion');
    expect(hyphenator.hyphenateWord('creative'), 'cre_ative');
    expect(hyphenator.hyphenateWord('disciplines'), 'dis_ci_plines');
  });

  // -------------------------------------------------------------------
  // syllablesWord()
  // -------------------------------------------------------------------

  test('hyphenate-word-to-syllables', () {
    final hyphenator = Hyphenator(config, symbol: '_');

    expect(hyphenator.syllablesWord('subdivision'),
        <String>['sub', 'di', 'vi', 'sion']);
    expect(hyphenator.syllablesWord('creative'), <String>['cre', 'ative']);
    expect(hyphenator.syllablesWord('disciplines'),
        <String>['dis', 'ci', 'plines']);
  });

  test('hyphenate-word-to-syllables-punctuation', () {
    final hyphenator = Hyphenator(config, symbol: '_');

    expect(hyphenator.syllablesWord('"subdivision"'),
        <String>['"sub', 'di', 'vi', 'sion"']);
    expect(
        hyphenator.syllablesWord('creative...'), <String>['cre', 'ative...']);
    expect(hyphenator.syllablesWord('disciplines,'),
        <String>['dis', 'ci', 'plines,']);
  });

  // -------------------------------------------------------------------
  // hyphenateTex()
  // -------------------------------------------------------------------

  test('hyphenate-text', () {
    final hyphenator = Hyphenator(config, symbol: '-');
    expect(hyphenator.hyphenateText(text), expectedText);
  });

  test('hyphenate-text-empty', () {
    final hyphenator = Hyphenator(config, symbol: '-');
    expect(hyphenator.hyphenateText(''), '');
  });

  test('hyphenate-text-boundaries', () {
    final text =
        """The arts are a vast subdivision of culture, composed of many creative endeavors and disciplines. 


        It is a broader term than     "art", which as a description of a field usually means only the visual arts.""";

    final expectedText =
        """The_ _arts_ _are_ _a_ _vast_ _sub_di_vi_sion_ _of_ _cul_ture,_ _com_posed_ _of_ _many_ _cre_ative_ _endeav_ors_ _and_ _dis_ci_plines._ _


_        _It_ _is_ _a_ _broader_ _term_ _than_     _"art",_ _which_ _as_ _a_ _descrip_tion_ _of_ _a_ _field_ _usu_ally_ _means_ _only_ _the_ _visual_ _arts.""";

    final hyphenator = Hyphenator(config, symbol: '_');
    expect(
        hyphenator.hyphenateText(text, hyphenAtBoundaries: true), expectedText);
  });

  // -------------------------------------------------------------------
  // hyphenateTextToTokens()
  // -------------------------------------------------------------------

  test('hyphenate-text-to-tokens', () {
    final text = """A vast subdivision of culture, 
        composed of many creative endeavors and disciplines.""";

    final hyphenator = Hyphenator(config);
    final result = hyphenator.hyphenateTextToTokens(text);

    expect(result.toString(),
        "[[A], WS, [vast], WS, [sub, di, vi, sion], WS, [of], WS, [cul, ture,], WS, NL, WS, [com, posed], WS, [of], WS, [many], WS, [cre, ative], WS, [endeav, ors], WS, [and], WS, [dis, ci, plines.]]");
  });

  test('hyphenate-wrapNoHyphen', () {
    final text = Text("""A vast subdivision of culture, 
        composed of many creative endeavors and disciplines.""");
    final expected = """A vast
subdivision of
culture,
composed of
many creative
endeavors and
disciplines.""";

    final WrapResult wrap = Hyphenator.wrapNoHyphen(text, sRoboto, 100);
    expect(wrap.textStr, expected);
  });

  // -------------------------------------------------------------------
  // wrap()
  // -------------------------------------------------------------------

  test('wrap-word-too-big', () {
    final str = 'hello';
    final styleBig = sRoboto.merge(TextStyle(fontSize: 500));
    final hyphenator = Hyphenator(config);
    final wrap = hyphenator.wrap(Text(str), styleBig, 350.0);
    expect(wrap.textStr, str);
    expect(wrap.size, Size(1069.0, 585.0));
    expect(wrap.isSizeMatching, false);
  });

  test('wrap-one-word', () {
    final str = 'hello';
    final hyphenator = Hyphenator(config);
    final wrap = hyphenator.wrap(Text(str), sRoboto, 360.0);
    expect(wrap.textStr, str);
    expect(wrap.size, Size(30, 16));
    expect(wrap.isSizeMatching, true);
  });

  test('wrap-two-words', () {
    final str = 'hello hello';
    final hyphenator = Hyphenator(config);
    final wrap = hyphenator.wrap(Text(str), sRoboto, 360.0);
    expect(wrap.textStr, str);
    expect(wrap.size, Size(64, 16));
    expect(wrap.isSizeMatching, true);
  });

  test('wrap-multiple-words-100-width', () {
    final style =
        TextStyle(fontWeight: FontWeight.normal, fontSize: 14).merge(sRoboto);
    final text = Text(
        """A vast subdivision of culture, composed of many creative endeavors and disciplines.""");
    final expected = """A vast subdivi-
sion of culture,
composed of
many creative
endeavors and
disciplines.""";

    final hyphenator = Hyphenator(config);

    WrapResult res = hyphenator.wrap(text, style, 100.0);
    // print(res.textStr);
    expect(res.isSizeMatching, true);
    expect(res.textStr, expected);
  });

  test('wrap-multiple-words-160-width', () {
    final style =
        TextStyle(fontWeight: FontWeight.normal, fontSize: 14).merge(sRoboto);
    final text = Text(
        """A vast subdivision of culture, composed of many creative endeavors and disciplines.""");
    final expected = """A vast subdivision of
culture, composed of
many creative endeavors
and disciplines.""";

    final hyphenator = Hyphenator(config);

    WrapResult res = hyphenator.wrap(text, style, 160.0);
    expect(res.isSizeMatching, true);
    expect(res.textStr, expected);
  });

  test('wrap-word-empty', () {
    final text = Text("");
    final expected = "";
    final hyphenator = Hyphenator(config);
    WrapResult res = hyphenator.wrap(text, sRoboto, 380.0);
    expect(res.isSizeMatching, true);
    expect(res.textStr, expected);
  });

  // -------------------------------------------------------------------
  // min letter count and min word length
  // -------------------------------------------------------------------

  test('hyphenate-test-minletter-4', () {
    final hyphenator = Hyphenator(config, symbol: '_', minLetterCount: 4);
    expect(hyphenator.hyphenateText('disciplines'), 'disci_plines');
  });

  test('hyphenate-test-minletter-50', () {
    final hyphenator = Hyphenator(config, symbol: '_', minLetterCount: 50);
    expect(hyphenator.hyphenateText('disciplines'), 'disciplines');
  });

  test('hyphenate-text-min-wordlength-50', () {
    final hyphenator = Hyphenator(config, symbol: '_', minWordLength: 50);
    expect(hyphenator.hyphenateText('disciplines'), 'disciplines');
  });

  // -------------------------------------------------------------------
  // stopwatch
  // -------------------------------------------------------------------

  test('stopwatch', () {
    final stopwatchesInit = <int>[];
    final stopwatchesPerform = <int>[];

    final stopwatchInit = Stopwatch()..start();
    final LanguageConfig config1 = Language_en_us();
    final hyphenator = Hyphenator(config1, symbol: '-');
    stopwatchInit.stop();
    stopwatchesInit.add(stopwatchInit.elapsedMilliseconds);

    for (int i = 0; i < 1; i++) {
      final stopwatchPerform = Stopwatch()..start();
      final result = hyphenator.hyphenateText(text);
      stopwatchPerform.stop();
      stopwatchesPerform.add(stopwatchPerform.elapsedMilliseconds);

      expect(result, expectedText);
    }

    final avgInit =
        stopwatchesInit.reduce((a, b) => a + b) / stopwatchesInit.length;
    final minInit = stopwatchesInit.reduce(Math.min);
    final maxInit = stopwatchesInit.reduce(Math.max);
    print('''
Stopwatch Init:
   #: ${stopwatchesInit.length}
 min: $minInit millis
 max: $maxInit millis
 avr: ${avgInit.toStringAsFixed(2)} millis = ${(avgInit * 1000).truncate()} micros
''');

    final avgPerform =
        stopwatchesPerform.reduce((a, b) => a + b) / stopwatchesPerform.length;
    final minPerform = stopwatchesPerform.reduce(Math.min);
    final maxPerform = stopwatchesPerform.reduce(Math.max);
    print('''
Stopwatch perform:
   #: ${stopwatchesPerform.length}
 min: $minPerform millis
 max: $maxPerform millis
 avr: ${avgPerform.toStringAsFixed(2)} millis = ${(avgPerform * 1000).truncate()} micros
''');
  });
}
