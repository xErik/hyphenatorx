/// The PREFIX language_ protects against Dart keywords like "is"
enum Language {
  language_af,
  language_as,
  language_bg,
  language_bn,
  language_ca,
  language_cop,
  language_cs,
  language_cy,
  language_da,
  language_de_1901,
  language_de_1996,
  language_de_ch_1901,
  language_el_monoton,
  language_el_polyton,
  language_en_gb,
  language_en_us,
  language_eo,
  language_es,
  language_et,
  language_eu,
  language_fi,
  language_fr,
  language_fur,
  language_ga,
  language_gl,
  language_grc,
  language_gu,
  language_hi,
  language_hr,
  language_hsb,
  language_hu,
  language_hy,
  language_ia,
  language_id,
  language_is,
  language_it,
  language_ka,
  language_kmr,
  language_kn,
  language_la_x_classic,
  language_la,
  language_lt,
  language_lv,
  language_ml,
  language_mn_cyrl_x_lmc,
  language_mn_cyrl,
  language_mr,
  language_mul_ethi,
  language_nb,
  language_nl,
  language_nn,
  language_or,
  language_pa,
  language_pl,
  language_pms,
  language_pt,
  language_rm,
  language_ro,
  language_ru,
  language_sa,
  language_sh_cyrl,
  language_sk,
  language_sl,
  language_sv,
  language_ta,
  language_te,
  language_th,
  language_tk,
  language_tr,
  language_uk,
  language_zh_latn_pinyin;

  static Language fromString(String lang) {
    Language l;
    final name = 'language_' + lang;
    try {
      l = Language.values.firstWhere((l) => l.name == name);
    } catch (e) {
      throw 'Language not found: $lang ($name). Try: ${abbreviations()}';
    }
    return l;
  }

  /// Returns abbreviations of available languages.
  static List<String> abbreviations() =>
      Language.values.map((e) => e.name.substring(9)).toList();
}
