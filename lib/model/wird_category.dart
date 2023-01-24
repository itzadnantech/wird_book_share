class Wird_Category {
  final String init_wird_cat_id;
  final String wird_cat_id;
  final String wird_cat_title;
  final String wird_cat_title_ar;

  const Wird_Category({
    required this.init_wird_cat_id,
    required this.wird_cat_id,
    required this.wird_cat_title,
    required this.wird_cat_title_ar,
  });

  factory Wird_Category.fromJson(Map<String, dynamic> json) => Wird_Category(
        init_wird_cat_id: json['init_wird_cat_id'],
        wird_cat_id: json['wird_cat_id'],
        wird_cat_title: json['wird_cat_title'],
        wird_cat_title_ar: json['wird_cat_title_ar'],
      );

  Map<String, dynamic> toJson() => {
        'init_wird_cat_id': init_wird_cat_id,
        'wird_cat_id': wird_cat_id,
        'wird_cat_title': wird_cat_title,
        'wird_cat_title_ar': wird_cat_title_ar,
      };
}
