// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pg_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PgTransaction {

@JsonKey(name: 'transactionId') String get transactionId;@JsonKey(name: 'customerId') String get customerId;@JsonKey(name: 'amount') double get amount;@JsonKey(name: 'status') String get status;@JsonKey(name: 'gateway') String get gateway;@JsonKey(name: 'orderId') String get orderId;@JsonKey(name: 'transactionDate') String get transactionDate;
/// Create a copy of PgTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PgTransactionCopyWith<PgTransaction> get copyWith => _$PgTransactionCopyWithImpl<PgTransaction>(this as PgTransaction, _$identity);

  /// Serializes this PgTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PgTransaction&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.gateway, gateway) || other.gateway == gateway)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactionId,customerId,amount,status,gateway,orderId,transactionDate);

@override
String toString() {
  return 'PgTransaction(transactionId: $transactionId, customerId: $customerId, amount: $amount, status: $status, gateway: $gateway, orderId: $orderId, transactionDate: $transactionDate)';
}


}

/// @nodoc
abstract mixin class $PgTransactionCopyWith<$Res>  {
  factory $PgTransactionCopyWith(PgTransaction value, $Res Function(PgTransaction) _then) = _$PgTransactionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'transactionId') String transactionId,@JsonKey(name: 'customerId') String customerId,@JsonKey(name: 'amount') double amount,@JsonKey(name: 'status') String status,@JsonKey(name: 'gateway') String gateway,@JsonKey(name: 'orderId') String orderId,@JsonKey(name: 'transactionDate') String transactionDate
});




}
/// @nodoc
class _$PgTransactionCopyWithImpl<$Res>
    implements $PgTransactionCopyWith<$Res> {
  _$PgTransactionCopyWithImpl(this._self, this._then);

  final PgTransaction _self;
  final $Res Function(PgTransaction) _then;

/// Create a copy of PgTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionId = null,Object? customerId = null,Object? amount = null,Object? status = null,Object? gateway = null,Object? orderId = null,Object? transactionDate = null,}) {
  return _then(_self.copyWith(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,gateway: null == gateway ? _self.gateway : gateway // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PgTransaction].
extension PgTransactionPatterns on PgTransaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PgTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PgTransaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PgTransaction value)  $default,){
final _that = this;
switch (_that) {
case _PgTransaction():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PgTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _PgTransaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'transactionId')  String transactionId, @JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'status')  String status, @JsonKey(name: 'gateway')  String gateway, @JsonKey(name: 'orderId')  String orderId, @JsonKey(name: 'transactionDate')  String transactionDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PgTransaction() when $default != null:
return $default(_that.transactionId,_that.customerId,_that.amount,_that.status,_that.gateway,_that.orderId,_that.transactionDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'transactionId')  String transactionId, @JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'status')  String status, @JsonKey(name: 'gateway')  String gateway, @JsonKey(name: 'orderId')  String orderId, @JsonKey(name: 'transactionDate')  String transactionDate)  $default,) {final _that = this;
switch (_that) {
case _PgTransaction():
return $default(_that.transactionId,_that.customerId,_that.amount,_that.status,_that.gateway,_that.orderId,_that.transactionDate);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'transactionId')  String transactionId, @JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'status')  String status, @JsonKey(name: 'gateway')  String gateway, @JsonKey(name: 'orderId')  String orderId, @JsonKey(name: 'transactionDate')  String transactionDate)?  $default,) {final _that = this;
switch (_that) {
case _PgTransaction() when $default != null:
return $default(_that.transactionId,_that.customerId,_that.amount,_that.status,_that.gateway,_that.orderId,_that.transactionDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PgTransaction implements PgTransaction {
  const _PgTransaction({@JsonKey(name: 'transactionId') this.transactionId = '', @JsonKey(name: 'customerId') this.customerId = '', @JsonKey(name: 'amount') this.amount = 0.0, @JsonKey(name: 'status') this.status = '', @JsonKey(name: 'gateway') this.gateway = '', @JsonKey(name: 'orderId') this.orderId = '', @JsonKey(name: 'transactionDate') this.transactionDate = ''});
  factory _PgTransaction.fromJson(Map<String, dynamic> json) => _$PgTransactionFromJson(json);

@override@JsonKey(name: 'transactionId') final  String transactionId;
@override@JsonKey(name: 'customerId') final  String customerId;
@override@JsonKey(name: 'amount') final  double amount;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'gateway') final  String gateway;
@override@JsonKey(name: 'orderId') final  String orderId;
@override@JsonKey(name: 'transactionDate') final  String transactionDate;

/// Create a copy of PgTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PgTransactionCopyWith<_PgTransaction> get copyWith => __$PgTransactionCopyWithImpl<_PgTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PgTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PgTransaction&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.gateway, gateway) || other.gateway == gateway)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transactionId,customerId,amount,status,gateway,orderId,transactionDate);

@override
String toString() {
  return 'PgTransaction(transactionId: $transactionId, customerId: $customerId, amount: $amount, status: $status, gateway: $gateway, orderId: $orderId, transactionDate: $transactionDate)';
}


}

/// @nodoc
abstract mixin class _$PgTransactionCopyWith<$Res> implements $PgTransactionCopyWith<$Res> {
  factory _$PgTransactionCopyWith(_PgTransaction value, $Res Function(_PgTransaction) _then) = __$PgTransactionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'transactionId') String transactionId,@JsonKey(name: 'customerId') String customerId,@JsonKey(name: 'amount') double amount,@JsonKey(name: 'status') String status,@JsonKey(name: 'gateway') String gateway,@JsonKey(name: 'orderId') String orderId,@JsonKey(name: 'transactionDate') String transactionDate
});




}
/// @nodoc
class __$PgTransactionCopyWithImpl<$Res>
    implements _$PgTransactionCopyWith<$Res> {
  __$PgTransactionCopyWithImpl(this._self, this._then);

  final _PgTransaction _self;
  final $Res Function(_PgTransaction) _then;

/// Create a copy of PgTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionId = null,Object? customerId = null,Object? amount = null,Object? status = null,Object? gateway = null,Object? orderId = null,Object? transactionDate = null,}) {
  return _then(_PgTransaction(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,gateway: null == gateway ? _self.gateway : gateway // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
