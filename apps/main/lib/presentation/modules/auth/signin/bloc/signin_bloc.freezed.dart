// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signin_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StateData {

 List<UserModel> get users; UserModel? get selectedUser;
/// Create a copy of _StateData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StateDataCopyWith<_StateData> get copyWith => __$StateDataCopyWithImpl<_StateData>(this as _StateData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StateData&&const DeepCollectionEquality().equals(other.users, users)&&(identical(other.selectedUser, selectedUser) || other.selectedUser == selectedUser));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(users),selectedUser);

@override
String toString() {
  return '_StateData(users: $users, selectedUser: $selectedUser)';
}


}

/// @nodoc
abstract mixin class _$StateDataCopyWith<$Res>  {
  factory _$StateDataCopyWith(_StateData value, $Res Function(_StateData) _then) = __$StateDataCopyWithImpl;
@useResult
$Res call({
 List<UserModel> users, UserModel? selectedUser
});




}
/// @nodoc
class __$StateDataCopyWithImpl<$Res>
    implements _$StateDataCopyWith<$Res> {
  __$StateDataCopyWithImpl(this._self, this._then);

  final _StateData _self;
  final $Res Function(_StateData) _then;

/// Create a copy of _StateData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? users = null,Object? selectedUser = freezed,}) {
  return _then(_self.copyWith(
users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<UserModel>,selectedUser: freezed == selectedUser ? _self.selectedUser : selectedUser // ignore: cast_nullable_to_non_nullable
as UserModel?,
  ));
}

}


/// Adds pattern-matching-related methods to [_StateData].
extension _StateDataPatterns on _StateData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __StateData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __StateData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __StateData value)  $default,){
final _that = this;
switch (_that) {
case __StateData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __StateData value)?  $default,){
final _that = this;
switch (_that) {
case __StateData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<UserModel> users,  UserModel? selectedUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __StateData() when $default != null:
return $default(_that.users,_that.selectedUser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<UserModel> users,  UserModel? selectedUser)  $default,) {final _that = this;
switch (_that) {
case __StateData():
return $default(_that.users,_that.selectedUser);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<UserModel> users,  UserModel? selectedUser)?  $default,) {final _that = this;
switch (_that) {
case __StateData() when $default != null:
return $default(_that.users,_that.selectedUser);case _:
  return null;

}
}

}

/// @nodoc


class __StateData implements _StateData {
  const __StateData({final  List<UserModel> users = const [], this.selectedUser}): _users = users;
  

 final  List<UserModel> _users;
@override@JsonKey() List<UserModel> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}

@override final  UserModel? selectedUser;

/// Create a copy of _StateData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_StateDataCopyWith<__StateData> get copyWith => __$_StateDataCopyWithImpl<__StateData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __StateData&&const DeepCollectionEquality().equals(other._users, _users)&&(identical(other.selectedUser, selectedUser) || other.selectedUser == selectedUser));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_users),selectedUser);

@override
String toString() {
  return '_StateData(users: $users, selectedUser: $selectedUser)';
}


}

/// @nodoc
abstract mixin class _$_StateDataCopyWith<$Res> implements _$StateDataCopyWith<$Res> {
  factory _$_StateDataCopyWith(__StateData value, $Res Function(__StateData) _then) = __$_StateDataCopyWithImpl;
@override @useResult
$Res call({
 List<UserModel> users, UserModel? selectedUser
});




}
/// @nodoc
class __$_StateDataCopyWithImpl<$Res>
    implements _$_StateDataCopyWith<$Res> {
  __$_StateDataCopyWithImpl(this._self, this._then);

  final __StateData _self;
  final $Res Function(__StateData) _then;

/// Create a copy of _StateData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? users = null,Object? selectedUser = freezed,}) {
  return _then(__StateData(
users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<UserModel>,selectedUser: freezed == selectedUser ? _self.selectedUser : selectedUser // ignore: cast_nullable_to_non_nullable
as UserModel?,
  ));
}


}

// dart format on
