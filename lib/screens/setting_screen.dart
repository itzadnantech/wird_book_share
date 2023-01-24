// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

///config file
import 'package:wird_book_share/config.dart' as config;

/// provider services
import 'package:provider/provider.dart';

/// shared preferences services
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird_book_share/localization/language_constants.dart';

/// screen
import 'package:wird_book_share/main.dart';

late String selected_lng;
// ignore: non_constant_identifier_names
String app_font = config.App_Arabic_Default_Font;
String quran_font = "Mushaf Uthmani";

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  double _value = config.fontSize_min;
  double _prevScale = config.prevScale;
  double _scale = config.scale;
  String Language = 'ar';

  @override
  void initState() {
    super.initState();
    get_font_size();
    _scale = config.scale;
    _prevScale = config.prevScale;
    getLanguage();
  }

  void getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      selected_lng = _prefs.getString(LAGUAGE_CODE) ?? "ar";
      quran_font = _prefs.getString('quran_font') ?? quran_font;
    });
  }

  ///get font size
  double get_font_size() {
    get_font_size_async();
    return _value;
  }

  get_font_size_async() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      Language = prefs.getString(LAGUAGE_CODE) ?? "ar";
    });
    _value = prefs.getDouble('value') ?? config.fontSize_min;
    _value = _value * _scale;
    if (_value > config.fontSize_max) {
      _value = config.fontSize_max;
    }

    if (_value < config.fontSize_min) {
      _value = config.fontSize_min;
    }
  }

  // ignore: non_constant_identifier_names
  void fontSizeSlider_async() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Language = prefs.getString(LAGUAGE_CODE) ?? "ar";
    });
    _value = prefs.getDouble('value') ?? config.fontSize_min;
    if (_value > config.fontSize_max) {
      _value = config.fontSize_max;
    }

    if (_value < config.fontSize_min) {
      _value = config.fontSize_min;
    }
    if (Language == "ar") {
      app_font = prefs.getString("app_font") ?? config.App_Arabic_Default_Font;
      setState(() {
        if (app_font == config.Arabic_Font) {
          _value = _value + 3;
        } else {
          _value = _value + config.arabic_font_increment;
        }
      });
    }
  }

  double fontSizeSlider() {
    fontSizeSlider_async();
    return _value;
  }

  final languages = [
    'Almushaf',
    'Noor',
    'Rustam',
    'Droid Nask',
    'Sakkal Majalla Regular',
    'Al Jazeera Arabic Bold',
    'Al Jazeera Arabic Regular',
  ];
  final languages_quran = [
    'Mushaf Madinah',
    'Mushaf Uthmani',
  ];
  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (ScaleUpdateDetails details) {
        setState(() {
          _scale = (_prevScale * (details.scale));
        });
      },
      onScaleEnd: (ScaleEndDetails details) {
        setState(() {
          _prevScale = _scale;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(config.colorPrimary),
          centerTitle: true,
          title: Text(
            getTranslated(context, 'SettingPage'),
          ),
        ),
        body: Stack(children: [
          Padding(
              padding: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 0),
              child: Column(children: <Widget>[
                Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          // color: Colors.grey.withOpacity(.9),
                          blurRadius: 0.2, // soften the shadow
                          // spreadRadius: 2.0, //extend the shadow
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, 'FontSize'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (Language == "ar")
                              ? get_font_size()
                              : get_font_size() - 2,
                          // color: Color(config.colorPrimary),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                          flex: 2,
                          child: ElevatedButton(
                            // onPressed: () {},
                            onPressed: () {
                              Provider.of<FontSizeController>(context,
                                      listen: false)
                                  .decrement();
                            },
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(5),
                                backgroundColor: Color(config.colorPrimary)),
                            child: Icon(
                              Icons.remove,
                            ),
                          )),
                      Flexible(flex: 12, child: buildSlider(context)),
                      Flexible(
                        flex: 2,
                        child: ElevatedButton(
                          // onPressed: () {},
                          onPressed: () {
                            Provider.of<FontSizeController>(context,
                                    listen: false)
                                .increment();
                          },
                          style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(5),
                              backgroundColor: Color(config.colorPrimary)),
                          child: Icon(
                            Icons.add,
                          ),
                        ),
                      )
                    ]),
                Container(
                    margin:
                        EdgeInsets.only(top: 8, bottom: 10, left: 8, right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          // color: Colors.grey.withOpacity(.9),
                          blurRadius: 0.2, // soften the shadow
                          // spreadRadius: 2.0, //extend the shadow
                        )
                      ],
                    ),
                    child: Center(
                        child: Text(
                      getTranslated(context, 'LanguageSetting'),
                      style: TextStyle(
                        fontSize: (Language == "ar")
                            ? get_font_size()
                            : get_font_size() - 2,
                        // color: Color(config.colorPrimary),
                        fontWeight: FontWeight.bold,
                      ),
                    ))),
                Language_Card(context),
                Container(
                  margin:
                      EdgeInsets.only(top: 10, bottom: 8, left: 8, right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        // color: Colors.grey.withOpacity(.9),
                        blurRadius: 0.2, // soften the shadow
                        // spreadRadius: 2.0, //extend the shadow
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      getTranslated(context, "appFontFamily"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (Language == "ar")
                            ? get_font_size()
                            : get_font_size() - 2,
                        // color: Color(config.colorPrimary),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: DropdownButton<String>(
                    items: languages.map(buildMenuItem).toList(),
                    value: app_font,
                    // isExpanded: true,
                    onChanged: (String? newValue) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        prefs.setString('app_font', newValue!);
                        app_font = newValue;
                      });
                    },
                  ),
                ),
                Container(
                    margin:
                        EdgeInsets.only(top: 10, bottom: 8, left: 8, right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          // color: Colors.grey.withOpacity(.9),
                          blurRadius: 0.2, // soften the shadow
                          // spreadRadius: 2.0, //extend the shadow
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, "quranFontFamily"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (Language == "ar")
                              ? get_font_size()
                              : get_font_size() - 2,
                          // color: Color(config.colorPrimary),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: DropdownButton<String>(
                    items: languages_quran.map(buildMenuItem).toList(),
                    value: quran_font,
                    // isExpanded: true,
                    onChanged: (String? newValue) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        prefs.setString('quran_font', newValue!);
                        quran_font = newValue;
                      });
                    },
                  ),
                ),
              ])),
          Get_Version(),
        ]),
      ),
    );
  }

  Widget Get_Version() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            config.version,
            style: TextStyle(fontSize: 10, color: Colors.grey),
          )),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          '{' + item + '}  ' + 'قُلْ يَا أَيُّهَا الْكَافِرُونَ',
          style: TextStyle(fontSize: 14, fontFamily: item),
        ),
      );

  Widget buildSlider(BuildContext context) {
    double _currentSliderValue = fontSizeSlider();
    return Slider(
      value: fontSizeSlider(),
      activeColor: Color(config.colorPrimary),
      max: config.fontSize_max, //20
      min: config.fontSize_min, //14R
      divisions: config.fontSize_devisions,
      label: fontSizeSlider().round().toString(),
      onChanged: (double value) {
        if (value < _currentSliderValue) {
          Provider.of<FontSizeController>(context, listen: false).decrement();
        } else {
          Provider.of<FontSizeController>(context, listen: false).increment();
        }
        setState(() {
          _currentSliderValue = value;
        });
      },
    );
  }

  @override
  // Language Card Section
  Widget Language_Card(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Flexible(
          flex: 2,
          child: ElevatedButton(
            onPressed: () async {
              selected_lng = 'en';
              Locale _locale = await setLocale('en');
              MyApp.setLocale(context, _locale);
            },
            style: ElevatedButton.styleFrom(
                fixedSize: Size(100, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    side: BorderSide(color: Color(config.colorPrimary))),
                padding:
                    EdgeInsets.only(top: 5, bottom: 5, right: 15, left: 15),
                backgroundColor: selected_lng == 'en'
                    ? Color(config.colorPrimary)
                    : Colors.white,
                foregroundColor: selected_lng == 'en'
                    ? Colors.white
                    : Color(config.colorPrimary)),
            child: Text('English'),
          )),
      SizedBox(width: 30),
      Flexible(
        flex: 2,
        child: ElevatedButton(
          onPressed: () async {
            selected_lng = 'ar';
            Locale _locale = await setLocale('ar');
            MyApp.setLocale(context, _locale);
          },
          style: ElevatedButton.styleFrom(
              fixedSize: Size(100, 30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(color: Color(config.colorPrimary))),
              padding: EdgeInsets.only(top: 5, bottom: 5, right: 15, left: 15),
              backgroundColor: selected_lng == 'ar'
                  ? Color(config.colorPrimary)
                  : Colors.white,
              foregroundColor: selected_lng == 'ar'
                  ? Colors.white
                  : Color(config.colorPrimary)),
          child: Text('العربية'.trim()),
        ),
      ),
    ]);
  }
}

///
///
/// *******************************************************************
/// *******************************************************************
/// ************* Class FontSize Controller ***************************
/// *******************************************************************
/// *******************************************************************

class FontSizeController with ChangeNotifier {
  double _value = config.fontSize_min;
  // Obtain shared preferences.

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _value = prefs.getDouble('value') ?? config.fontSize_min;
  }

  double fontSize() {
    init();
    return _value;
  }

  double get value => fontSize();
  void increment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _value = ((prefs.getDouble('value') ?? config.fontSize_min) + 0.02);
    if (_value > config.fontSize_max) {
      _value = config.fontSize_max;
    }
    prefs.setDouble('value', _value);
    notifyListeners();
  }

  void decrement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _value = ((prefs.getDouble('value') ?? config.fontSize_min) - 0.02);
    if (_value < config.fontSize_min) {
      _value = config.fontSize_min;
    }
    prefs.setDouble('value', _value);
    notifyListeners();
  }
}
