class Wird_Sub_Category {
  final String wird_cat_id;
  final String wird_sub_cat_id;
  final String wird_sub_cat_title;
  final String wird_sub_cat_title_ar;
  final String wird_audio_link;
  final int audio_duration;

  const Wird_Sub_Category({
    required this.wird_cat_id,
    required this.wird_sub_cat_id,
    required this.wird_sub_cat_title,
    required this.wird_sub_cat_title_ar,
    required this.wird_audio_link,
    required this.audio_duration,
  });

  factory Wird_Sub_Category.fromJson(Map<String, dynamic> json) =>
      Wird_Sub_Category(
        wird_cat_id: json['wird_cat_id'],
        wird_sub_cat_id: json['wird_sub_cat_id'],
        wird_sub_cat_title: json['wird_sub_cat_title'],
        wird_sub_cat_title_ar: json['wird_sub_cat_title_ar'],
        wird_audio_link: json['wird_audio_link'],
        audio_duration: json['audio_duration'],
      );

  Map<String, dynamic> toJson() => {
        'wird_cat_id': wird_cat_id,
        'wird_sub_cat_id': wird_sub_cat_id,
        'wird_sub_cat_title': wird_sub_cat_title,
        'wird_sub_cat_title_ar': wird_sub_cat_title_ar,
        'wird_audio_link': wird_audio_link,
        'audio_duration': audio_duration,
      };
}
