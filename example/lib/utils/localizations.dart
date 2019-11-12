import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class DemoLocalizations {
  final Locale locale;
  DemoLocalizations(this.locale);

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'conversation': 'Conversation',
      'address_book': 'Address Book',
      'setting': 'Setting',
      'login': 'Login',
    },
    'zh': {
      'conversation': '会话',
      'address_book': '通讯录',
      'setting': '设置',
      'login': '登录',
    }
  };

  get conversation {
    return _localizedValues[locale.languageCode]['conversation'];
  }
  get addressBook {
    return _localizedValues[locale.languageCode]['address_book'];
  }
  get setting {
    return _localizedValues[locale.languageCode]['setting'];
  }
  get login {
    return _localizedValues[locale.languageCode]['login'];
  }
  static DemoLocalizations of(BuildContext context) {
    return Localizations.of(context, DemoLocalizations);
  }
}

class DemoLocalizationsDelegate extends LocalizationsDelegate<DemoLocalizations>{
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en','zh'].contains(locale.languageCode);
  }

  @override
  Future<DemoLocalizations> load(Locale locale) {
    return new SynchronousFuture<DemoLocalizations>(new DemoLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<DemoLocalizations> old) {
    return false;
  }

  static DemoLocalizationsDelegate delegate = const DemoLocalizationsDelegate();
}