class FilterQuery {
  final String attribute;
  final String operation;
  final dynamic value;

  FilterQuery(this.attribute, this.operation, this.value);

  FilterQuery.contains({this.attribute, this.value}) : operation = 'in';

  FilterQuery.notIn({this.attribute, this.value}) : operation = 'not_in';

  FilterQuery.allInArray({this.attribute, List<String> value})
      : operation = 'all_in_array',
        value = value.reduce((previous, current) => ',$current');

  FilterQuery.inArray({this.attribute, List<String> value})
      : operation = 'in_array',
        value = value.reduce((previous, current) => ',$current');

  FilterQuery.greaterThanDate({this.attribute, this.value})
      : operation = 'gt-date';

  FilterQuery.lessThanDate({this.attribute, this.value})
      : operation = 'lt-date';

  FilterQuery.greaterThanInt({this.attribute, this.value})
      : operation = 'gt-int';

  FilterQuery.lessThanInt({this.attribute, this.value}) : operation = 'lt-int';

  FilterQuery.greaterThanFloat({this.attribute, this.value})
      : operation = 'gt-float';

  FilterQuery.lessThanFloat({this.attribute, this.value})
      : operation = 'lt-float';
}
