// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, unrelated_type_equality_checks, depend_on_referenced_packages, avoid_unnecessary_containers

import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wird_book_share/classes/Audio.dart';
import 'package:wird_book_share/classes/appbar.dart';
import 'package:wird_book_share/common.dart';

///config file
import 'package:wird_book_share/config.dart' as config;
import 'package:wird_book_share/data/all_wird_sub_cats.dart';
import 'package:wird_book_share/localization/language_constants.dart';
import 'package:wird_book_share/model/wird_sub_category.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:wird_book_share/screens/setting_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class QuranScreen extends StatefulWidget {
  final AudioPlayerHandler audioHandler;
  const QuranScreen(this.audioHandler, {Key? key}) : super(key: key);

  @override
  _QuranScreenState createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late final AnimationController _controller;
  // final _controller = AnimationController;

  late double _value = config.fontSize_min;
  double _prevScale = config.prevScale;
  double _scale = config.scale;

  ///Config Quran
  late List Arabic_Quran;
  late List English_Quran;
  late List Audio_Quran;
  String Surah_Name = '';
  String Surah_List = '';
  late int total_quran_pages = 604;
  // int total_quran_pages = 5;
  int page_number = 0;
  int Page_no = 1;
  bool next_page = true;
  late SharedPreferences pref;
  // AudioPlayerHandler get audioHandler => widget.audioHandler;
  AudioPlayerHandler get audioHandler => widget.audioHandler;

  ///loader
  bool _loader = true;
  late Duration position;

  ///language check
  String Language = 'ar';
  String app_font = config.App_Arabic_Default_Font;
  late String quran_font;

  ///Swiper
  SwiperController controller = SwiperController();

  @override
  void initState() {
    super.initState();
    FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _Init_Quran_Config();
    get_font_size();
    _scale = config.scale;
    _prevScale = config.prevScale;
  }

  _Init_Quran_Config() async {
    pref = await SharedPreferences.getInstance();
    DownloadAudios();
    // pref.setInt("duration_49", 70413);
    Arabic_Quran = await Get_Arabic_Quran();
    English_Quran = await Get_English_Quran();
    // await Get_Duration(pref);
    await Audio_Config();
    await Language_Code();
    Audio_Quran = await Get_Audios_of_Quran();
    int audio_position = Audio_Quran[page_number]['position'];
    int audio_duration = 70413 - audio_position;
    pref.setInt(
      "position_49",
      audio_position,
    );
    pref.setInt(
      "duration_49",
      audio_duration,
    );
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
      var key = "${list[i].wird_cat_id}_${list[i].wird_sub_cat_id}";
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

  Audio_Config() async {
    late List<Wird_Sub_Category> subwirds;
    final list = all_wird_sub_cats.toList();
    audioHandler.skipToQueueItem(list.length - 1);
  }

  Get_Audios_of_Quran() async {
    const String file = 'lib/quran/page_wise_audio_format.json';
    final String response = await rootBundle.loadString(file);
    final data = await json.decode(response);
    return data['data']['pages'];
  }

  Get_Arabic_Quran() async {
    const String file = 'lib/quran/Arabic_Quran.json';
    final String response = await rootBundle.loadString(file);
    final data = await json.decode(response);
    return data['data']['pages'];
  }

  Get_English_Quran() async {
    const String file = 'lib/quran/English_Quran.json';
    final String response = await rootBundle.loadString(file);
    final data = await json.decode(response);
    return data['data']['pages'];
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
    final screenHeight = MediaQuery.of(context).size.height;
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
        onTap: () => setState(() => _visible = !_visible),
        child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: SlidingAppBar(
                controller: _controller,
                visible: _visible,
                child: AppBar(
                    backgroundColor: Color(config.colorPrimary),
                    centerTitle: true,
                    title: Text(
                      // getTranslated(context, 'quran'),
                      Surah_List,
                      style: TextStyle(fontSize: 16),
                    ),
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingPage()));
                          }),
                    ])),
            body: _loader
                ? CircularProgressIndicator()
                : Stack(children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0, left: 10, right: 10, bottom: 15),
                      child: Swiper(
                        controller: controller,
                        loop: true,
                        onIndexChanged: (index) {
                          next_page = true;
                          page_number = index;
                          int audio_position =
                              Audio_Quran[page_number]['position'];
                          int audio_duration = 70413 - audio_position;
                          pref.setInt(
                            "position_49",
                            audio_position,
                          );
                          pref.setInt(
                            "duration_49",
                            audio_duration,
                          );
                          audioHandler.skipToQueueItem(49);

                          setState(() {
                            Page_no = index + 1;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Print_Single_Page(screenHeight);
                        },
                        itemCount: total_quran_pages,
                      ),
                    ),
                    _Get_Page_Number(),
                  ])
            // bottomNavigationBar: (_visible)
            //     ? Container(
            //         height: 60,
            //         color: Color(config.colorPrimary),
            //         child: InkWell(
            //           onTap: () => showModal(context),
            //           child: const Center(
            //             child: Icon(
            //               Icons.search,
            //               color: Colors.white,
            //             ),
            //           ),
            //         ),
            //       )
            //     : null,
            ));
  }

  ///Get Page Number
  Widget _Get_Page_Number() {
    return Align(
        alignment:
            (Page_no.isEven) ? Alignment.bottomLeft : Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: Container(
              width: 50,
              height: 28,
              // margin: const EdgeInsets.only(top: 10),
              // padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/page_banner.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                child: Text(
                  getTranslated(context, Page_no.toString()),
                  // Page_no.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: (Language == "ar")
                          ? "Mushaf Uthmani"
                          : config.App_English_Default_Font,
                      // fontFamily: config.App_English_Default_Font,
                      fontSize: 16),
                ),
              )),
        ));
  }

  Widget Print_Single_Page(screeHeight) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    // if (currentOrientation == Orientation.landscape) {
    //   print("Your Mobile mode is landscape:");
    // }
    Language_Code();
    Audio_Syncronization();

    // next_page = true;
    bool page_check = false;
    final Page = Language == "ar"
        ? Arabic_Quran[page_number]
        : English_Quran[page_number];
    final page_ayahs = Page['ayahs'];
    final page_surahs = Page['surahs'];
    Page_no = Page['number'];
    if (Page_no == 1 || Page_no == 2) {
      page_check = true;
    }
    final total_surahs = page_surahs.length;
    Surah_List = '';
    for (var i = 0; i < total_surahs; i++) {
      // ignore: prefer_interpolation_to_compose_strings
      if (i == 0) {
        Surah_List =
            Get_Page_Surah_Name(page_surahs[i]).replaceAll('سُورَةُ', '');
        continue;
      } else {
        // ignore: prefer_interpolation_to_compose_strings
        Surah_List = '$Surah_List / ' +
            Get_Page_Surah_Name(page_surahs[i]).replaceAll('سُورَةُ', '');
      }
    }

    return SingleChildScrollView(
        child: Column(children: [
      // level one
      ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
        leading: Text(
          Surah_List,
        ),
        iconColor: Color(config.colorPrimary),
      ),
      //level two
      Visibility(
          visible: true,
          child: Container(
            height: 0,
            child: StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data ??
                    PositionData(
                        Duration(seconds: pref.getInt("position_49") ?? 0),
                        Duration.zero,
                        Duration(seconds: pref.getInt("duration_49") ?? 70413));
                // print("Next Page Postion is:");
                // print(pref.getInt("next_position"));
                if (positionData.position.inSeconds ==
                    (pref.getInt("next_position")! - 1)) {
                  next_page = true;
                  if (next_page) {
                    (page_number == total_quran_pages - 1)
                        ? page_number = 0
                        : page_number++;
                  }
                  next_page = false;
                }

                return SeekBar(
                  language: pref.getString(LAGUAGE_CODE) ?? "ar",
                  position: positionData.position,
                  duration: positionData.duration,
                  onChangeEnd: null,
                  // onChangeEnd: (newPosition) {
                  //   audioHandler.seek(newPosition);
                  // },
                );
              },
            ),
          )),
      Container(height: 40, child: ControlButtons(audioHandler)),
      for (var i = 0; i < total_surahs; i++) ...[
        if (Get_Surah_Title(page_ayahs, page_surahs[i]['number'])) ...[
          if (page_check)
            const SizedBox(
              height: 50,
            ),
          Container(
            // color: Colors.green,
            width: (currentOrientation == Orientation.landscape) ? 600 : 400,
            // height: 35,
            margin: const EdgeInsets.only(bottom: 2, top: 3),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Color(config.colorPrimary),
              image: const DecorationImage(
                image: AssetImage("assets/images/surah_banner.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
                child: Text(
              Get_Page_Surah_Name(page_surahs[i]),
              style: TextStyle(
                  color: Color(config.colorQuran),
                  fontSize: (currentOrientation == Orientation.landscape)
                      ? 50
                      : (total_surahs == 1)
                          ? 16
                          : (total_surahs == 2)
                              ? 12
                              : 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: quran_font),
            )),
          ),
          Container(
              width: (currentOrientation == Orientation.landscape) ? 300 : 200,
              height: (currentOrientation == Orientation.landscape) ? 35 : 20,
              margin: const EdgeInsets.only(bottom: 2, top: 2),
              // padding: EdgeInsets.all(10),
              decoration: const BoxDecoration(
                // color: Colors.blueAccent,
                image: DecorationImage(
                  image: AssetImage("assets/images/bismillah_banner.jpg"),
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: null),
        ],
        Container(
            // color: Colors.green,
            height: (currentOrientation == Orientation.landscape)
                ? null
                : (page_check)
                    ? screeHeight * 0.55
                    : (total_surahs == 1)
                        ? screeHeight * 0.86
                        : (total_surahs == 2)
                            ? screeHeight * 0.40
                            : screeHeight * 0.18,
            child: (currentOrientation == Orientation.landscape || page_check)
                ? Get_Text(page_ayahs, page_surahs[i]['number'], page_check,
                    currentOrientation)
                : Get_AutoSize(page_ayahs, page_surahs[i]['number'], page_check,
                    currentOrientation)),
      ],
    ]));
  }

  Get_AutoSize(page_ayahs, page_surahs_number, page_check, currentOrientation) {
    return AutoSizeText(
        Get_Page_Ayahs(
          page_ayahs,
          page_surahs_number,
        ),
        maxLines: (Language == "ar") ? 25 : 35,
        minFontSize: (Language == "ar")
            ? (quran_font == "Mushaf Madinah")
                ? 17
                : 17
            : 16,
        // style: TextStyle(fontSize: 20),
        textAlign: (page_check == true) ? TextAlign.center : TextAlign.justify,
        style: TextStyle(
            decoration: (Language == "ar")
                ? (quran_font == "Mushaf Madinah")
                    ? TextDecoration.underline
                    : TextDecoration.none
                : null,
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 0.3,
            color: Color(config.colorQuran),
            fontSize: (currentOrientation == Orientation.landscape)
                ? (Language == "ar")
                    ? 50
                    : 35
                : (Language == "ar")
                    ? 28
                    : 18,
            fontWeight: (Language == "ar")
                ? (quran_font == "Mushaf Madinah")
                    ? FontWeight.w400
                    : FontWeight.w400
                : FontWeight.w700,
            fontFamily:
                (Language == "ar") ? quran_font : "App_English_Default_Font"));
  }

  Get_Text(page_ayahs, page_surahs_number, page_check, currentOrientation) {
    return Text(
        Get_Page_Ayahs(
          page_ayahs,
          page_surahs_number,
        ),
        // style: TextStyle(fontSize: 20),
        textAlign: (page_check) ? TextAlign.center : TextAlign.justify,
        style: TextStyle(
            decoration: (Language == "ar")
                ? (quran_font == "Mushaf Madinah")
                    ? TextDecoration.underline
                    : TextDecoration.none
                : null,
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 0.3,
            color: Color(config.colorQuran),
            fontSize: (currentOrientation == Orientation.landscape)
                ? (Language == "ar")
                    ? 50
                    : 35
                : (Language == "ar")
                    ? 28
                    : 18,
            fontWeight: (Language == "ar")
                ? (quran_font == "Mushaf Madinah")
                    ? FontWeight.w200
                    : FontWeight.w400
                : FontWeight.w700,
            fontFamily:
                (Language == "ar") ? quran_font : "App_English_Default_Font"));
  }

  Audio_Syncronization() {
    // audioHandler.skipToQueueItem(49);
    int audio_position = Audio_Quran[page_number]['position'];
    int audio_duration = 70413 - audio_position;
    pref.setInt(
      "position_49",
      audio_position,
    );
    pref.setInt(
      "duration_49",
      audio_duration,
    );

    int next_page = (page_number == total_quran_pages - 1)
        ? 0
        : Audio_Quran[page_number + 1]['position'];
    pref.setInt(
      "next_position",
      next_page,
    );
  }

  Get_Page_Ayahs(ayahs, number) {
    String all_ayahs = '';
    for (var i = 0; i < ayahs.length; i++) {
      if (ayahs[i]['surah']['number'] != number) continue;
      if (ayahs[i]['numberInSurah'] == 1) {
        ayahs[i]['text'] = ayahs[i]['text']
            .replaceAll('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '');
        ayahs[i]['text'] = ayahs[i]['text']
            .replaceAll('بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '');
      }
      // ignore: prefer_interpolation_to_compose_strings
      if (Language == "ar" && quran_font == "Mushaf Madinah") {
        all_ayahs =
            // ignore: prefer_interpolation_to_compose_strings
            '${'${all_ayahs + ayahs[i]['text']} ' + getTranslated(context, ayahs[i]['numberInSurah'].toString())} ';
      } else {
        all_ayahs =
            // ignore: prefer_interpolation_to_compose_strings
            '${'${all_ayahs + ayahs[i]['text']} (' + getTranslated(context, ayahs[i]['numberInSurah'].toString())}) ';
      }
    }
    return all_ayahs;
  }

  Get_Surah_Title(ayahs, number) {
    bool check = false;
    for (var i = 0; i < ayahs.length; i++) {
      if (ayahs[i]['numberInSurah'] == 1 &&
          ayahs[i]['surah']['number'] == number) check = true;
    }
    return check;
  }

  Get_Page_Surah_Name(surah) {
    Language_Code();
    return Language == "ar" ? surah['name'] : surah['englishName'];
  }

  Language_Code() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Language = prefs.getString(LAGUAGE_CODE) ?? "ar";
    quran_font = prefs.getString('quran_font') ?? "Mushaf Uthmani";
  }

  Widget CircularProgressIndicator() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
            alignment: Alignment.center,
            child: LoadingAnimationWidget.beat(
              color: Color(config.colorPrimary),
              size: 30,
            )));
  }

  prev_Slide() {
    setState(() {
      page_number--;
    });
    controller.previous(animation: true);
  }

  next_Slide() {
    setState(() {
      page_number++;
    });
    controller.next(animation: true);
  }

  void showModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Coming Soon'),
        actions: <TextButton>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          )
        ],
      ),
    );
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
