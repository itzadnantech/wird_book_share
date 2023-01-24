/// *******************************************************************
/// *******************************************************************
/// ************* Home Page *******************************************
/// *******************************************************************
/// *******************************************************************
// ignore_for_file: unused_import, unrelated_type_equality_checks, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:wird_book_share/classes/Audio.dart';

///config file
import 'package:wird_book_share/config.dart' as config;

///common file
import 'package:wird_book_share/common.dart';

/// provider services
import 'package:provider/provider.dart';

/// shared preferences services
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird_book_share/screens/home_screen.dart';
import 'package:wird_book_share/screens/wirds_screen.dart';

/// Widgets classes
import 'package:wird_book_share/widget/search_widget.dart';

///Localization classes
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wird_book_share/localization/language_constants.dart';
import 'package:wird_book_share/localization/demo_localization.dart';

///model classes
import 'package:wird_book_share/model/wird_category.dart';
import 'package:wird_book_share/model/wird_sub_category.dart';
import 'package:wird_book_share/model/wird.dart';

///data classes
import 'package:wird_book_share/data/all_wird_cats.dart';
import 'package:wird_book_share/data/all_wird_sub_cats.dart';
import 'package:wird_book_share/data/all_wirds.dart';

///audio services
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

///progress bars services
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';

/// screens
import 'package:wird_book_share/main.dart';
import 'package:wird_book_share/screens/setting_screen.dart';
import 'package:wird_book_share/screens/sub_wirds_screen.dart';
import 'package:wird_book_share/screens/quran_screen.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../data/init_wird_cats.dart';
import '../model/init_category.dart';

late AudioPlayerHandler audioHandler;

class InitScreen extends StatefulWidget {
  const InitScreen({Key? key}) : super(key: key);

  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  final formKey = GlobalKey<FormState>();
  final _queryController = TextEditingController();
  late List<Init_Wird_Category> list_wird_category;
  // late SharedPreferences prefs;

  String query = '';
  double _value = config.fontSize_min;
  double _prevScale = config.prevScale;
  double _scale = config.scale;
  String Language = "ar";
  bool run = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => init_audio_services(context));
    get_font_size();
    list_wird_category = init_all_wird_cats;
    _scale = config.scale;
    _prevScale = config.prevScale;
  }

  init_audio_services(context) async {
    final prefs = await SharedPreferences.getInstance();
    DownloadAudios();
    audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandlerImpl(prefs),
      config: const AudioServiceConfig(
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );

    Timer(Duration(seconds: 3), () {
      run = true;
    });
  }

  DownloadAudios() async {
    final pref = await SharedPreferences.getInstance();
    late List<Wird_Sub_Category> subwirds;
    final list = all_wird_sub_cats.toList();
    for (int i = 0; i < list.length; i++) {
      var url = list[i].wird_audio_link;
      var key = list[i].wird_cat_id + "_" + list[i].wird_sub_cat_id;
      var fetchedFile = await DefaultCacheManager().getFileFromCache(key);
      if (fetchedFile?.file == null) {
        await DefaultCacheManager().downloadFile(url, key: key);
        var fetchedFile = await DefaultCacheManager().getFileFromCache(key);
        var file_url = fetchedFile?.file.path.toString();
        await pref.setString(key, file_url ?? "");
        print("Your donwloading Cache File $key");
        print(pref.getString(key));
      } else {
        var fetchedFile = await DefaultCacheManager().getFileFromCache(key);
        var file_url = fetchedFile?.file.path.toString();
        await pref.setString(key, file_url ?? "");
        print("Your Cache File $key");
        print(pref.getString(key));
      }
    }
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

  @override
  Widget build(BuildContext context) {
    var body_one = Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: list_wird_category.length,
              itemBuilder: (context, index) {
                return buildWirdCategoryList(
                    list_wird_category[index], context);
              },
            ),
          ),
        ],
      ),
    );

    var body_two = Center(
      child: Column(children: [
        SizedBox(height: 100),
        Flexible(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                "assets/images/logo.jpg",
                height: 200.0,
                width: 150.0,
              ),
            )),
        Flexible(
            flex: 2,
            child: Container(
                child: const Text(
              "كِتَابُ الأَوْرَادِ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ))),
        Flexible(
            child: Container(
                child: const Text(
          "مجموعة الأوراد الشريفة القادرية الشاذلية",
          style: TextStyle(fontSize: 15),
        ))),
        Flexible(
            flex: 2,
            child: Container(
                margin: EdgeInsets.only(top: 10),
                child: const Text("The Wird Book",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25)))),
        Flexible(
            child: Container(
                margin: EdgeInsets.only(top: 0),
                child: const Text("Litany of the Qadiri Shadhili Order",
                    style: TextStyle(fontSize: 13)))),
        Flexible(
            child: Container(
                // margin: const EdgeInsets.only(top: 10),
                child: Center(
                    child: Text(
          config.version,
          style: TextStyle(fontSize: 10, color: Colors.grey),
        )))),
      ]),
    );
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
        appBar: (run == true)
            ? AppBar(
                backgroundColor: Color(config.colorPrimary),
                centerTitle: true,
                title: Text(
                  getTranslated(context, 'homePage'),
                ),
                leading: IconButton(
                    icon: const Icon(Icons.search_sharp),
                    onPressed: () {
                      showSearchModal(context);
                    }),
                actions: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        _navigateToSettingPage(context);
                      }),
                ],
              )
            : null,
        body: (run) ? body_one : body_two,
      ),
    );
  }

  void showSearchModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Container(
            height: 140,
            child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _queryController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please enter search text";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10),
                        hintText: getTranslated(context, 'search'),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Color(config.colorPrimary),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              BorderSide(color: Color(config.colorPrimary)),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          searchWirdCategory(_queryController.text);
                        }
                      },
                      child: Text(getTranslated(context, 'submit')),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(config.colorPrimary)),
                    ),
                  ],
                ))),
        actions: <TextButton>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              getTranslated(context, 'close'),
              style: TextStyle(color: Color(config.colorPrimary)),
            ),
          )
        ],
      ),
    );
  }

  Widget buildWirdCategoryList(
          Init_Wird_Category single_wird_category, context) =>
      Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 0.1, // soften the shadow
                spreadRadius: 0.2, //extend the shadow
              )
            ],
          ),
          child: Center(
              key: null,
              child: ListTile(
                contentPadding: const EdgeInsets.only(
                    left: 10, right: 10, top: 0, bottom: 3),
                title: Text(
                  (Language == "ar")
                      ? single_wird_category.init_wird_cat_title_ar
                      : single_wird_category.init_wird_cat_title,
                  style: TextStyle(
                    fontSize: (Language == "ar")
                        ? get_font_size()
                        : get_font_size() - 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  (Language == "ar")
                      ? single_wird_category.init_wird_cat_title
                      : single_wird_category.init_wird_cat_title_ar,
                  style: TextStyle(
                    color: Color(config.colorPrimary),
                    height: 1,
                    fontSize: (Language == "ar")
                        ? get_font_size() - 3
                        : get_font_size() - 3,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(config.colorPrimary),
                      size: 20,
                    ),
                  ],
                ),
                onTap: () =>
                    {Move_to_next_page(single_wird_category.init_wird_cat_id)},
                // isThreeLine: true,
              )
              // onTap: single_wird_category.init_wird_cat_id == "3"
              // onTap: Move_to_next_page(single_wird_category.init_wird_cat_id)),
              ));

  void searchWirdCategory(String query) {
    print("Your query is $query");
    final list_wird_category = init_all_wird_cats.where((single_wird_category) {
      final single_wird_category_Lower =
          single_wird_category.init_wird_cat_title.toLowerCase();
      final searchLower = query.toLowerCase();

      ///for arabic
      final wird_cat_title_ar_search =
          single_wird_category.init_wird_cat_title_ar;
      return single_wird_category_Lower.contains(searchLower) ||
          wird_cat_title_ar_search.contains(query);
    }).toList();

    if (list_wird_category.isNotEmpty) {
      setState(() {
        this.query = query;
        this.list_wird_category = list_wird_category;
      });
    }
    Navigator.pop(context);
  }

  ///Setting Page
  void _navigateToSettingPage(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SettingPage()));
  }

  void Move_to_next_page(id) {
    var page;
    switch (id) {
      case "1":
        page = HomeScreen(id, audioHandler);
        break;
      case "2":
        page = HomeScreen(id, audioHandler);
        break;
      case "3":
        page = QuranScreen(audioHandler);
        break;
      case "4":
        page = AllWirdSubCatPage("10", "Appendix", audioHandler);
        break;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
