import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_employee.freezed.dart';
part 'service_employee.g.dart';

@freezed
sealed class ServiceEmployee with _$ServiceEmployee {
  const factory ServiceEmployee({
    @JsonKey(name: 'employeeId') required String employeeId,
    @JsonKey(name: 'employeeName') required String employeeName,
    @JsonKey(name: 'phone') String? phone,
    @JsonKey(name: 'serviceArea') String? serviceArea,
  }) = _ServiceEmployee;

  factory ServiceEmployee.fromJson(Map<String, dynamic> json) =>
      _$ServiceEmployeeFromJson(json);
}
