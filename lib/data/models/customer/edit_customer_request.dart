import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_customer_request.freezed.dart';
part 'edit_customer_request.g.dart';

@freezed
sealed class EditCustomerRequest with _$EditCustomerRequest {
  const factory EditCustomerRequest({
    @JsonKey(name: 'customerId') required String customerId,
    @JsonKey(name: 'firstName') required String firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'mobileNumber') required String mobileNumber,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'billingAddress1') String? billingAddress1,
    @JsonKey(name: 'billingAddress2') String? billingAddress2,
    @JsonKey(name: 'installationAddress1') String? installationAddress1,
    @JsonKey(name: 'installationAddress2') String? installationAddress2,
    @JsonKey(name: 'pinCode') String? pinCode,
    @JsonKey(name: 'gender') String? gender,
    @JsonKey(name: 'idType') String? idType,
    @JsonKey(name: 'idNumber') String? idNumber,
    @JsonKey(name: 'customerTypeId') String? customerTypeId,
    @JsonKey(name: 'customerTypeTypesId') String? customerTypeTypesId,
    @JsonKey(name: 'groupId') String? groupId,
    @JsonKey(name: 'cafNumber') String? cafNumber,
    @JsonKey(name: 'lcoCustomerId') String? lcoCustomerId,
    @JsonKey(name: 'businessName') String? businessName,
    @JsonKey(name: 'fatherName') String? fatherName,
    @JsonKey(name: 'accountNumber') String? accountNumber,
    @JsonKey(name: 'billType') String? billType,
    @JsonKey(name: 'dob') String? dob,
    @JsonKey(name: 'doa') String? doa,
    @JsonKey(name: 'discount') double? discount,
    @JsonKey(name: 'remarks') String? remarks,
    @JsonKey(name: 'countryCode') String? countryCode,
    @JsonKey(name: 'stateId') String? stateId,
    @JsonKey(name: 'districtId') String? districtId,
    @JsonKey(name: 'cityId') String? cityId,
    @JsonKey(name: 'mandalId') String? mandalId,
    @JsonKey(name: 'latitude') double? latitude,
    @JsonKey(name: 'longitude') double? longitude,
    @JsonKey(name: 'changeAddress', defaultValue: false) required bool changeAddress,
    @JsonKey(name: 'changeInstallAddress', defaultValue: false) required bool changeInstallAddress,
    @JsonKey(name: 'uploadDocs', defaultValue: false) required bool uploadDocs,
    @JsonKey(name: 'idPhoto') String? idPhoto,
    @JsonKey(name: 'customerPhoto') String? customerPhoto,
    @JsonKey(name: 'signatureImage') String? signatureImage,
  }) = _EditCustomerRequest;

  factory EditCustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$EditCustomerRequestFromJson(json);
}
