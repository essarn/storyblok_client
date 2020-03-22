import 'enums.dart';

class SortBy {
  final String attributeField;
  final String contentField;
  final SortOrder order;
  final SortType type;

  SortBy({this.attributeField, this.contentField, this.order, this.type})
      : assert(attributeField != null ? contentField == null : true),
        assert(contentField != null ? attributeField == null : true);
}
