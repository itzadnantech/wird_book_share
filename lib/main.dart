// ignore_for_file: unnecessary_this, unnecessary_null_comparison,non_constant_identifier_names,depend_on_referenced_packages, prefer_const_constructors, no_leading_underscores_for_local_identifiers, use_build_context_synchronously,library_private_types_in_public_api,

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

///config file
import 'package:wird_book_share/config.dart' as config;

/// provider services
import 'package:provider/provider.dart';

///Localization classes
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wird_book_share/screens/init_screen.dart';
import 'localization/language_constants.dart';
import 'package:wird_book_share/localization/demo_localization.dart';

/// screen

import 'package:wird_book_share/screens/setting_screen.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);
  // var cron = new Cron();
  // cron.schedule(new Schedule.parse('*/30 * * * *'), () async {
  //   DownloadAudios();
  // });
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FontSizeController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String Language = "ar";
  late Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  ///get_font_family
  get_font_family_async() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      app_font = prefs.getString("app_font") ?? config.App_Arabic_Default_Font;
      Language = prefs.getString(LAGUAGE_CODE) ?? "ar";
    });
  }

  get_font_family() {
    get_font_family_async();
    return Language == "ar" ? app_font : config.App_English_Default_Font;
  }

  @override
  Widget build(BuildContext context) {
    if (this._locale == null) {
      return Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
              alignment: Alignment.center,
              child: LoadingAnimationWidget.beat(
                color: Color(config.colorPrimary),
                size: 30,
              )));
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Wird Book App",
        theme: ThemeData(
            primaryColor: Color(config.colorPrimary),
            fontFamily: get_font_family(),
            listTileTheme: ListTileThemeData(
              textColor: Color(config.colorQuran),
            ),
            textTheme: TextTheme(
              bodyText1: TextStyle(fontSize: 22.0),
            )),
        locale: _locale,
        supportedLocales: const [
          Locale("en", "US"),
          Locale("ar", "SA"),
        ],
        localizationsDelegates: const [
          DemoLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode &&
                supportedLocale.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        // home: HomeScreen(),
        home: InitScreen(),
      );
    }
  }

  void dispose() {
    FullScreen.exitFullScreen();
    super.dispose();
  }
}
