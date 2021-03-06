<?php

namespace Laminas\Mvc\I18n;

use Laminas\I18n\Translator\TranslatorInterface as I18nTranslatorInterface;

class DummyTranslator implements I18nTranslatorInterface
{
    public function translate($message, $textDomain = 'default', $locale = null)
    {
        return $message;
    }

    public function translatePlural($singular, $plural, $number, $textDomain = 'default', $locale = null)
    {
        return ($number == 1 ? $singular : $plural);
    }
}
