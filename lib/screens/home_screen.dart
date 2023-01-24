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

class HomeScreen extends StatefulWidget {
  final String init_wird_cat_id;
  final AudioPlayerHandler audioHandler;
  const HomeScreen(this.init_wird_cat_id, this.audioHandler);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final formKey = GlobalKey<FormState>();
  final _queryController = TextEditingController();
  late List<Wird_Category> list_wird_category;

  late List<Wird_Sub_Category> subwirds;
  late List all_wird_cats_new;
  final list = all_wird_sub_cats.toList();
  String query = '';
  double _value = config.fontSize_min;
  double _prevScale = config.prevScale;
  double _scale = config.scale;
  String Language = "ar";

  @override
  void initState() {
    super.initState();
    get_font_size();
    list_wird_category = all_wird_cats
        .where((element) => element.init_wird_cat_id == widget.init_wird_cat_id)
        .toList();
    _scale = config.scale;
    _prevScale = config.prevScale;
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
                final single_wird_category = list_wird_category[index];
                return buildWirdCategoryList(single_wird_category, context);
              },
            ),
          ),
        ],
      ),
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
          appBar: AppBar(
            backgroundColor: Color(config.colorPrimary),
            centerTitle: true,
            title: Text(
              getTranslated(context, 'homePage'),
            ),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    _navigateToSettingPage(context);
                  }),
            ],
          ),
          body: body_one),
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

  Widget buildWirdCategoryList(Wird_Category single_wird_category, context) =>
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
              contentPadding:
                  const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 3),
              title: Text(
                (Language == "ar")
                    ? single_wird_category.wird_cat_title_ar
                    : single_wird_category.wird_cat_title,
                style: TextStyle(
                  fontSize: (Language == "ar")
                      ? get_font_size()
                      : get_font_size() - 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                (Language == "ar")
                    ? single_wird_category.wird_cat_title
                    : single_wird_category.wird_cat_title_ar,
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
              onTap: single_wird_category.wird_cat_id == "7"
                  ? () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuranScreen(
                                    widget.audioHandler,
                                  )));
                    }
                  : () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllWirdSubCatPage(
                                    single_wird_category.wird_cat_id,
                                    single_wird_category.wird_cat_title,
                                    widget.audioHandler,
                                  )));
                    },
            )),
      );

  void searchWirdCategory(String query) {
    print("Your query is $query");
    final list_wird_category = all_wird_cats.where((single_wird_category) {
      final single_wird_category_Lower =
          single_wird_category.wird_cat_title.toLowerCase();
      final searchLower = query.toLowerCase();

      ///for arabic
      final wird_cat_title_ar_search = single_wird_category.wird_cat_title_ar;
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
}
