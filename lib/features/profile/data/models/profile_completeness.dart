class ProfileCompleteness {
  final bool isComplete;
  final int completionPercentage;
  final List<MissingField> missingFields;
  final int totalFields;
  final int completedFields;

  const ProfileCompleteness({
    required this.isComplete,
    required this.completionPercentage,
    required this.missingFields,
    required this.totalFields,
    required this.completedFields,
  });

  factory ProfileCompleteness.fromJson(Map<String, dynamic> json) {
    return ProfileCompleteness(
      isComplete: json['isComplete'] as bool,
      completionPercentage: json['completionPercentage'] as int,
      missingFields: (json['missingFields'] as List<dynamic>)
          .map((field) => MissingField.fromJson(field as Map<String, dynamic>))
          .toList(),
      totalFields: json['totalFields'] as int,
      completedFields: json['completedFields'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isComplete': isComplete,
      'completionPercentage': completionPercentage,
      'missingFields': missingFields.map((field) => field.toJson()).toList(),
      'totalFields': totalFields,
      'completedFields': completedFields,
    };
  }

  @override
  String toString() {
    return 'ProfileCompleteness{isComplete: $isComplete, completionPercentage: $completionPercentage%, completedFields: $completedFields/$totalFields}';
  }
}

class MissingField {
  final String field;
  final String label;
  final bool required;

  const MissingField({
    required this.field,
    required this.label,
    required this.required,
  });

  factory MissingField.fromJson(Map<String, dynamic> json) {
    return MissingField(
      field: json['field'] as String,
      label: json['label'] as String,
      required: json['required'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'label': label,
      'required': required,
    };
  }

  @override
  String toString() {
    return 'MissingField{field: $field, label: $label, required: $required}';
  }
}
