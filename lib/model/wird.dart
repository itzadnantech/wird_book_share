class Wird {
  final String wird_cat_id;
  final String wird_sub_cat_id;
  final String wird_id;
  final String wird_description;
  final String wird_audio_link;
  final String repetition;

  const Wird({
    required this.wird_cat_id,
    required this.wird_sub_cat_id,
    required this.wird_id,
    required this.wird_description,
    required this.wird_audio_link,
    required this.repetition,
  });

  factory Wird.fromJson(Map<String, dynamic> json) => Wird(
        wird_cat_id: json['wird_cat_id'],
        wird_sub_cat_id: json['wird_sub_cat_id'],
        wird_id: json['wird_id'],
        wird_description: json['wird_description'],
        wird_audio_link: json['wird_audio_link'],
        repetition: json['repetition'],
      );

  Map<String, dynamic> toJson() => {
        'wird_cat_id': wird_cat_id,
        'wird_sub_cat_id': wird_sub_cat_id,
        'wird_id': wird_id,
        'wird_description': wird_description,
        'wird_audio_link': wird_audio_link,
        'repetition': repetition,
      };
}
