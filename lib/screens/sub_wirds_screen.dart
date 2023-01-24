// ignore_for_file: unnecessary_this, unnecessary_null_comparison,non_constant_identifier_names,depend_on_referenced_packages, prefer_const_constructors, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, unused_import

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wird_book_share/classes/Audio.dart';

///config file
import 'package:wird_book_share/config.dart' as config;

///common file
import 'package:wird_book_share/common.dart';

/// provider services
import 'package:provider/provider.dart';

/// shared preferences services
import 'package:shared_preferences/shared_preferences.dart';

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

/// screen
import 'package:wird_book_share/screens/setting_screen.dart';
import 'package:wird_book_share/screens/wirds_screen.dart';
import 'package:wird_book_share/main.dart';

class AllWirdSubCatPage extends StatefulWidget {
  final String wird_cat_id;
  final String wird_cat_title;
  final AudioPlayerHandler audioHandler;
  const AllWirdSubCatPage(
      this.wird_cat_id, this.wird_cat_title, this.audioHandler);

  @override
  _AllWirdSubCatPageState createState() => _AllWirdSubCatPageState();
}

class _AllWirdSubCatPageState extends State<AllWirdSubCatPage> {
  late List<Wird_Sub_Category> subwirds;

  double _value = config.fontSize_min;
  double _prevScale = config.prevScale;
  double _scale = config.scale;

  String Language = "ar";
  String app_font = config.App_Arabic_Default_Font;

  @override
  void initState() {
    super.initState();
    get_font_size();
    _scale = config.scale;
    _prevScale = config.prevScale;
    subwirds = all_wird_sub_cats
        .where((medium) => medium.wird_cat_id == widget.wird_cat_id)
        .toList();
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
      app_font = prefs.getString('app_font') ?? config.App_Arabic_Default_Font;
    });
    _value = prefs.getDouble('value') ?? config.fontSize_min;
    _value = _value * _scale;
    if (_value > config.fontSize_max) {
      _value = config.fontSize_max;
    }

    if (_value < config.fontSize_min) {
      _value = config.fontSize_min;
    }

    // if (Language == "ar") {
    //   app_font = prefs.getString("app_font") ?? config.App_Arabic_Default_Font;
    //   setState(() {
    //     if (app_font == config.Arabic_Font) {
    //       _value = _value + 3;
    //     } else {
    //       _value = _value + config.arabic_font_increment;
    //     }
    //   });
    // }
  }

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
            getTranslated(context, 'wird_cat_id_${widget.wird_cat_id}'),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SettingPage()));
                }),
          ],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: subwirds.length,
                itemBuilder: (context, index) {
                  final subwird = subwirds[index];

                  return buildBook(subwird, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget buildBook(Wird_Sub_Category list, context) => Container(
        // margin: EdgeInsets.all(15),
        margin: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              // color: Colors.grey.withOpacity(.9),
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
                    ? list.wird_sub_cat_title_ar
                    : list.wird_sub_cat_title,
                style: TextStyle(
                  fontSize: (Language == "ar")
                      ? get_font_size()
                      : get_font_size() - 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                (Language == "ar")
                    ? list.wird_sub_cat_title
                    : list.wird_sub_cat_title_ar,
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
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AllWirdsPage(
                            widget.audioHandler,
                            list.wird_cat_id,
                            list.wird_sub_cat_id,
                            list.wird_sub_cat_title,
                            list.wird_audio_link)));
              },
            )),
      );
}
