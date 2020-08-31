# frozen_string_literal: true

module Gitlab
  module I18n
    extend self

    # Languages with less then 2% of available translations will not
    # be available in the UI.
    # https://gitlab.com/gitlab-org/gitlab/-/issues/221012
    NOT_AVAILABLE_IN_UI = %w[
      fil_PH
      pl_PL
      nl_NL
      id_ID
      cs_CZ
      bg
      eo
      gl_ES
    ].freeze

    # "translated" needs to be externalized
    AVAILABLE_LANGUAGES = {
      'bg' => 'Bulgarian - български (2% translated)',
      'cs_CZ' => 'Czech - čeština (1% translated)',
      'de' => 'German - Deutsch (31% translated)',
      'en' => 'English (100% translated)',
      'eo' => 'Esperanto - esperanto (2% translated)',
      'es' => 'Spanish - español (65% translated)',
      'fil_PH' => 'Filipino (1% translated)',
      'fr' => 'French - français (23% translated)',
      'gl_ES' => 'Galician - galego (1% translated)',
      'id_ID' => 'Indonesian - Bahasa Indonesia (0% translated)',
      'it' => 'Italian - italiano (4% translated)',
      'ja' => 'Japanese - 日本語 (67% translated)',
      'ko' => 'Korean - 한국어 (21% translated)',
      'nl_NL' => 'Dutch - Nederlands (1% translated)',
      'pl_PL' => 'Polish - polski (1% translated)',
      'pt_BR' => 'Portuguese (Brazil) - português (Brasil) (36% translated)',
      'ru' => 'Russian - Русский (48% translated)',
      'tr_TR' => 'Turkish - Türkçe (24% translated)',
      'uk' => 'Ukrainian - українська (68% translated)',
      'zh_CN' => 'Chinese, Simplified - 简体中文 (100% translated)',
      'zh_HK' => 'Chinese, Traditional (Hong Kong) - 繁體中文 (香港) (4% translated)',
      'zh_TW' => 'Chinese, Traditional (Taiwan) - 繁體中文 (台灣) (6% translated)'
    }.freeze

    TRANSLATION_LEVELS = {
      'bg' => '2%',
      'cs_CZ' => '1%',
      'de' => '31%',
      'en' => '100%',
      'eo' => '2%',
      'es' => '65%',
      'fil_PH' => '1%',
      'fr' => '23%',
      'gl_ES' => '1%',
      'id_ID' => '0%',
      'it' => '4%',
      'ja' => '67%',
      'ko' => '21%',
      'nl_NL' => '1%',
      'pl_PL' => '1%',
      'pt_BR' => '36%',
      'ru' => '48%',
      'tr_TR' => '24%',
      'uk' => '68%',
      'zh_CN' => '100%',
      'zh_HK' => '4%',
      'zh_TW' => '6%'
    }.freeze

    def selectable_locales
      AVAILABLE_LANGUAGES.reject { |key, _value| NOT_AVAILABLE_IN_UI.include? key }
    end

    def available_locales
      AVAILABLE_LANGUAGES.keys
    end

    def locale
      FastGettext.locale
    end

    def locale=(locale_string)
      requested_locale = locale_string || ::I18n.default_locale
      new_locale = FastGettext.set_locale(requested_locale)
      ::I18n.locale = new_locale
    end

    def use_default_locale
      FastGettext.set_locale(::I18n.default_locale)
      ::I18n.locale = ::I18n.default_locale
    end

    def with_locale(locale_string)
      original_locale = locale

      self.locale = locale_string
      yield
    ensure
      self.locale = original_locale
    end

    def with_user_locale(user, &block)
      with_locale(user&.preferred_language, &block)
    end

    def with_default_locale(&block)
      with_locale(::I18n.default_locale, &block)
    end
  end
end
