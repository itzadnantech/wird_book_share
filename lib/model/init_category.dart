class Init_Wird_Category {
  final String init_wird_cat_id;
  final String init_wird_cat_title;
  final String init_wird_cat_title_ar;

  const Init_Wird_Category({
    required this.init_wird_cat_id,
    required this.init_wird_cat_title,
    required this.init_wird_cat_title_ar,
  });

  factory Init_Wird_Category.fromJson(Map<String, dynamic> json) =>
      Init_Wird_Category(
        init_wird_cat_id: json['init_wird_cat_id'],
        init_wird_cat_title: json['init_wird_cat_title'],
        init_wird_cat_title_ar: json['init_wird_cat_title_ar'],
      );

  Map<String, dynamic> toJson() => {
        'init_wird_cat_id': init_wird_cat_id,
        'init_wird_cat_title': init_wird_cat_title,
        'init_wird_cat_title_ar': init_wird_cat_title_ar,
      };
}
