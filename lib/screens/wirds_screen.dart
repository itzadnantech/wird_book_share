// ignore_for_file: unnecessary_this, unnecessary_null_comparison,non_constant_identifier_names,depend_on_referenced_packages, prefer_const_constructors, no_leading_underscores_for_local_identifiers, use_build_context_synchronously,library_private_types_in_public_api, prefer_typing_uninitialized_variables, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wird_book_share/classes/Audio.dart';

///config file
import 'package:wird_book_share/config.dart' as config;

///common file
import 'package:wird_book_share/common.dart';

/// shared preferences services
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird_book_share/localization/language_constants.dart';

import 'package:wird_book_share/model/wird_sub_category.dart';
import 'package:wird_book_share/model/wird.dart';

import 'package:wird_book_share/data/all_wird_sub_cats.dart';
import 'package:wird_book_share/data/all_wirds.dart';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

///card_swiper services
import 'package:card_swiper/card_swiper.dart';

import 'package:linear_progress_bar/linear_progress_bar.dart';

import 'package:wird_book_share/screens/setting_screen.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// You might want to provide this using dependency injection rather than a
// global variable.

// late final AudioPlayerHandler audioHandler;

class AllWirdsPage extends StatefulWidget {
  final String wird_cat_id;
  final String wird_sub_cat_id;
  final String wird_sub_cat_title;
  final String wird_audio_link;
  final AudioPlayerHandler audioHandler;

  const AllWirdsPage(this.audioHandler, this.wird_cat_id, this.wird_sub_cat_id,
      this.wird_sub_cat_title, this.wird_audio_link,
      {super.key});

  @override
  _AllWirdsPageState createState() => _AllWirdsPageState();
}

class _AllWirdsPageState extends State<AllWirdsPage>
    with SingleTickerProviderStateMixin {
  late List<Wird_Sub_Category> sub_wirds;
  late List<Wird_Sub_Category> sub_wird_list;
  late List<Wird> wirds;
  late List Single_wird_list;
  String pageTitle = "...";
  late SharedPreferences pref;
  int start_index = 0;
  int init_point = 0;
  int end_index = 0;
  bool slide_push = true;
  int audio_init_point = 0;
  late final Surah_List;
  late int total_wirds;
  late double _value = config.fontSize_min;
  double _prevScale = config.prevScale;
  double _scale = config.scale;
  SwiperController controller = SwiperController();
  final ScrollController _controller = new ScrollController();
  late AnimationController _animationController;
  AudioPlayerHandler get audioHandler => widget.audioHandler;

  var reachEnd = false;
  bool _loader = true;
  bool check = true;
  String Language = "ar";
  late String app_font;
  late String quran_font;

  _listener() {
    final maxScroll = _controller.position.maxScrollExtent;
    final minScroll = _controller.position.minScrollExtent;
    if (_controller.offset >= maxScroll) {
      setState(() {
        reachEnd = true;
      });
    }
    if (_controller.offset == minScroll) {
      setState(() {
        reachEnd = false;
      });
    }
  }

  @override
  void initState() {
    _controller.addListener(_listener);
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    Timer(Duration(milliseconds: 1000), () => _animationController.forward());

    super.initState();
    _init();
    get_font_size();
    _scale = config.scale;
    _prevScale = config.prevScale;
  }

  _init() async {
    pref = await SharedPreferences.getInstance();

    ///get_sub_wirds_list
    await get_sub_wirds_list();
    await get_sub_wirds_list_new();
    DownloadAudios();

    ///Page title
    pageTitle =
        "wird_sub_cat_id_${widget.wird_cat_id}_${widget.wird_sub_cat_id}";

    await Language_Code();
    await Get_app_font();
    Surah_List = await Get_Surah_List();
    setState(() {
      _loader = false;
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

  ///get_sub_wirds_list
  get_sub_wirds_list() async {
    sub_wirds = all_wird_sub_cats
        .where((element) => element.wird_cat_id == widget.wird_cat_id)
        .toList();
  }

  get_sub_wirds_list_new() async {
    sub_wird_list = all_wird_sub_cats.toList();
    get_sub_wirds_list_new_start_index();
    get_sub_wirds_list_new_end_index();
    get_sub_wirds_list_new_initial_point();
  }

  get_sub_wirds_list_new_start_index() {
    for (var i = 0; i < sub_wird_list.length; i++) {
      if (sub_wird_list[i].wird_cat_id == widget.wird_cat_id) {
        start_index = i;
        break;
      }
    }
  }

  get_sub_wirds_list_new_end_index() {
    for (var i = 0; i < sub_wird_list.length; i++) {
      if (sub_wird_list[i].wird_cat_id == widget.wird_cat_id) {
        end_index = i;
      }
    }
  }

  get_sub_wirds_list_new_initial_point() {
    for (var i = 0; i < sub_wird_list.length; i++) {
      if (sub_wird_list[i].wird_cat_id == widget.wird_cat_id &&
          sub_wird_list[i].wird_sub_cat_id == widget.wird_sub_cat_id) {
        init_point = i;
        audio_init_point = init_point;
        break;
      }
    }
  }

  Get_Surah_List() async {
    const String file = 'lib/quran/Surah_List.json';
    final String response = await rootBundle.loadString(file);
    final data = await json.decode(response);
    return data['data'];
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Language_Code() async {
    Language = pref.getString(LAGUAGE_CODE) ?? "ar";
    quran_font = pref.getString('quran_font') ?? "Mushaf Uthmani";
  }

  Get_app_font() async {
    Language = pref.getString(LAGUAGE_CODE) ?? "ar";
    app_font = pref.getString('app_font') ?? config.App_Arabic_Default_Font;
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
            getTranslated(context, pageTitle),
          ),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SettingPage()));
                }),
          ],
        ),
        body: _loader
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(0),
                child: Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(),
                    ),
                    child: Column(
                      children: [
                        Flexible(
                          flex: 22,
                          child: Swiper(
                            controller: controller,
                            loop: false,
                            index: init_point,
                            onIndexChanged: (index) {
                              print("Your index number is:$index");
                              if (index >= start_index && index <= end_index) {
                                init_point = index;
                                reachEnd = false;
                                final single_sub_wird = sub_wird_list[index];
                                pageTitle =
                                    "wird_sub_cat_id_${single_sub_wird.wird_cat_id}_${single_sub_wird.wird_sub_cat_id}";
                                Audio_Config(init_point);
                                slide_push = true;
                              }
                            },
                            itemBuilder: (BuildContext context, int index) {
                              final single_sub_wird = sub_wird_list[index];

                              if (audio_init_point == init_point &&
                                  check == true) {
                                Audio_Config(audio_init_point);
                                check = false;
                              }

                              wirds = all_wirds
                                  .where((medium) =>
                                      medium.wird_cat_id ==
                                          single_sub_wird.wird_cat_id &&
                                      medium.wird_sub_cat_id ==
                                          single_sub_wird.wird_sub_cat_id)
                                  .toList();
                              final total_wirds = wirds.length;
                              return _buildListItem(
                                  single_sub_wird,
                                  single_sub_wird.wird_cat_id,
                                  single_sub_wird.wird_sub_cat_id,
                                  single_sub_wird.audio_duration,
                                  wirds,
                                  total_wirds,
                                  index);
                            },
                            itemCount: sub_wird_list.length,
                          ),
                        ),
                        if (reachEnd)
                          Flexible(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                      height: 60,
                                      child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 1),
                                            end: Offset.zero,
                                          ).animate(_animationController),
                                          child: FadeTransition(
                                              opacity: _animationController,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: ElevatedButton(
                                                        onPressed: init_point >
                                                                start_index
                                                            ? () => prev_Slide()
                                                            : null,
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                fixedSize: Size(
                                                                    100, 0),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20.0),
                                                                  // side: BorderSide(color: Color(config.colorPrimary))
                                                                ),
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            5),
                                                                backgroundColor:
                                                                    Color(config
                                                                        .colorPrimary),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white),
                                                        child: Text(
                                                          getTranslated(
                                                              context, "Prev"),
                                                        ),
                                                        // child: Text("
                                                        // "),
                                                      ),
                                                    ),
                                                    SizedBox(width: 40),
                                                    SizedBox(width: 40),
                                                    Flexible(
                                                      child: ElevatedButton(
                                                        onPressed: init_point <
                                                                end_index
                                                            ? () => next_Slide()
                                                            : null,
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                fixedSize: Size(
                                                                    100, 0),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20.0),
                                                                  // side: BorderSide(color: Color(config.colorPrimary))
                                                                ),
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            5),
                                                                backgroundColor:
                                                                    Color(config
                                                                        .colorPrimary),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white),
                                                        child: Text(
                                                          getTranslated(
                                                              context, 'Next'),
                                                        ),
                                                      ),
                                                    ),
                                                  ]))))))
                      ],
                    )),
              ),
      ),
    );
  }

  Widget _buildListItem(single_sub_wird, wird_cat_id, wird_sub_cat_id,
      audio_duration, wirds, total_wirds, index) {
    return Column(
      children: <Widget>[
        Flexible(
            flex: 1,
            child: Container(
                padding:
                    const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 2),
                child: LinearProgressBar(
                  maxSteps: int.parse((sub_wirds.length).toString()),
                  progressType: LinearProgressBar
                      .progressTypeLinear, // Use Linear progress
                  currentStep: int.parse(single_sub_wird.wird_sub_cat_id),
                  progressColor: Color(config.colorPrimary),
                  backgroundColor: Colors.grey,
                ))),
        Flexible(
          flex: 2,
          child: StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              var _position = pref.getInt("position_$init_point") ?? 0;
              final positionData = snapshot.data ??
                  PositionData(Duration(seconds: _position), Duration.zero,
                      Duration(seconds: audio_duration));
              //Set save position and duration
              pref.setInt(
                "position_$init_point",
                positionData.position.inSeconds,
              );

              if (positionData.position.inSeconds == audio_duration) {
                (slide_push)
                    ? Timer(Duration(seconds: 1), () async {
                        pref.remove("position_${init_point}");
                        (init_point == end_index)
                            ? Audio_Config(end_index)
                            : next_Slide();
                      })
                    : null;

                (init_point == end_index)
                    ? audioHandler.stop()
                    : slide_push = false;
              }

              return SeekBar(
                language: pref.getString(LAGUAGE_CODE) ?? "ar",
                position: positionData.position,
                duration: positionData.duration,
                onChangeEnd: (newPosition) {
                  audioHandler.seek(newPosition);
                },
              );
            },
          ),
        ),
        // ControlButtons(audioHandler)
        Flexible(
            flex: 2,
            // child: ControlButtons(audioHandler, start_index, end_index)),
            child: ControlButtons(audioHandler)),

        Flexible(
            flex: 19,
            child: Scrollbar(
              controller: _controller,
              thumbVisibility: true,
              radius: Radius.circular(10),
              thickness: 2,
              child: ListView.builder(
                shrinkWrap: true,
                controller: _controller,
                itemCount: total_wirds,
                itemBuilder: (context, index) {
                  final single_wird = wirds[index];
                  final repetition_number = single_wird.repetition;

                  String wird_translate =
                      "wird_id_${single_wird.wird_cat_id}_${single_wird.wird_sub_cat_id}_${single_wird.wird_id}";
                  String wird_count =
                      '${getTranslated(context, 'wird')}  ${getTranslated(context, single_wird.wird_id)}';
                  String Repetition = (repetition_number == '0' ||
                          repetition_number == '1')
                      ? " "
                      : '${getTranslated(context, 'repetition')}  ${getTranslated(context, single_wird.repetition)}';

                  return _buildWirdsListItem_one(single_wird, wird_translate,
                      Repetition, wird_count, index, context);
                },
              ),
            )),

        // const SizedBox(height: 20),
      ],
    );
  }

  prev_Slide() {
    setState(() {
      init_point = init_point - 1;
    });
    controller.previous(animation: true);
  }

  next_Slide() {
    init_point = init_point + 1;
    controller.next(animation: true);
  }

  first_Slide() {
    init_point = 0;
    controller.next(animation: true);
    // controller.addListener(() {});
  }

  CircularProgressIndicator() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
            alignment: Alignment.center,
            child: LoadingAnimationWidget.beat(
              color: Color(config.colorPrimary),
              size: 30,
            )));
  }

  Widget _buildWirdsListItem_one(single_wird, wird_translate, Repetition,
      wird_count, i, BuildContext context) {
    Language_Code();
    Get_app_font();
    bool surah_content = false;
    List Surah_data = [];
    String wird_description = "";
    switch (wird_translate) {
      case "wird_id_8_8_1":
        surah_content = true;
        Surah_data = (Language == "ar")
            ? Surah_List['18_ayahs_ar']
            : Surah_List['18_ayahs_en'];
        break;
      case "wird_id_1_11_1":
        surah_content = true;
        Surah_data = (Language == "ar")
            ? Surah_List['36_ayahs_ar']
            : Surah_List['36_ayahs_en'];
        break;
      case "wird_id_8_7_1":
        surah_content = true;
        Surah_data = (Language == "ar")
            ? Surah_List['36_ayahs_ar']
            : Surah_List['36_ayahs_en'];
        break;
      case "wird_id_8_9_1":
        surah_content = true;
        Surah_data = (Language == "ar")
            ? Surah_List['44_ayahs_ar']
            : Surah_List['44_ayahs_en'];
        break;

      case "wird_id_1_12_1":
        surah_content = true;
        Surah_data = (Language == "ar")
            ? Surah_List['56_ayahs_ar']
            : Surah_List['56_ayahs_en'];
        break;
      case "wird_id_5_5_1":
        surah_content = true;
        Surah_data = (Language == "ar")
            ? Surah_List['56_ayahs_ar']
            : Surah_List['56_ayahs_en'];
        break;
      case "wird_id_6_5_1":
        surah_content = true;
        Surah_data = (Language == "ar")
            ? Surah_List['67_ayahs_ar']
            : Surah_List['67_ayahs_en'];
        break;
      default:
    }
    wird_description = getTranslated(context, wird_translate);

    // print(Surah_data);
    if (surah_content) {
      wird_description = "";
      for (var i = 0; i < Surah_data.length; i++) {
        if (Surah_data[i]['numberInSurah'] == 1) {
          Surah_data[i]['text'] = Surah_data[i]['text']
              .replaceAll('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '');
          Surah_data[i]['text'] = Surah_data[i]['text']
              .replaceAll('بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '');
        }
        // if (i == 0) {
        //   Surah_data[i]['text'] = Surah_data[i]['text']
        //       .replaceAll('بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ', '');
        // }
        // ignore: prefer_interpolation_to_compose_strings
        wird_description =
            // ignore: prefer_interpolation_to_compose_strings
            '${'${wird_description + Surah_data[i]['text']} (' + getTranslated(context, Surah_data[i]['numberInSurah'].toString())}) ';
      }
    } else {
      wird_description = getTranslated(context, wird_translate);
    }

    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(),
        ),
        margin: const EdgeInsets.only(top: 3, bottom: 3),
        // color: Color.fromARGB(255, 216, 224, 236),
        color: Color.fromARGB(255, 248, 249, 252),
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Column(children: <Widget>[
              Text(
                // getTranslated(context, wird_translate),
                wird_description,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  decoration: (Language == "ar")
                      ? (quran_font == "Mushaf Madinah") && (surah_content)
                          ? TextDecoration.underline
                          : TextDecoration.none
                      : null,
                  color: Color(config.colorQuran),
                  fontSize: (Language == "ar")
                      ? (surah_content)
                          ? 22
                          : get_font_size()
                      : get_font_size() - 2,
                  fontWeight: (Language == "ar")
                      ? (quran_font == "Mushaf Madinah")
                          ? FontWeight.w200
                          : FontWeight.w300
                      : FontWeight.w700,
                  fontFamily: (Language == "ar")
                      ? (surah_content)
                          ? quran_font
                          : app_font
                      : config.App_English_Default_Font,
                ),
              ),
              Text(Repetition,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w200,
                    color: Color.fromARGB(255, 15, 134, 19),
                    fontFamily: app_font,
                  )),
            ])));
  }

  Audio_Config(audio_number) async {
    audioHandler.skipToQueueItem(audio_number);
  }

  Stream<Duration>? get _bufferedPositionStream => audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();
  Stream<Duration?>? get _durationStream =>
      audioHandler.mediaItem.map((item) => item?.duration).distinct();
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          AudioService.position,
          _bufferedPositionStream!,
          _durationStream!,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));
}
