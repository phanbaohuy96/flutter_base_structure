import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

// ignore: constant_identifier_names
const LOT_NUMBER_UNKNOWN = 'UNKNOWN';

enum AppointmentStatus {
  neww,
  confirmed,
  completed,
  canceled,
}

extension AppointmentStatusExt on AppointmentStatus {
  static String? toJson(AppointmentStatus? s) {
    return s?.status;
  }

  String get status {
    switch (this) {
      case AppointmentStatus.neww:
        return 'new';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.canceled:
        return 'canceled';
    }
  }

  static AppointmentStatus? of(dynamic value) {
    final status = asOrNull<String>(value);
    for (final e in AppointmentStatus.values) {
      if (e.status == status) {
        return e;
      }
    }
    return null;
  }
}

enum ConsultationBehavior {
  @JsonValue('general')
  general('general'),

  @JsonValue('warranty')
  warranty('warranty');

  const ConsultationBehavior(this.value);

  final String value;
}

enum AppointmentType {
  @JsonValue('service')
  service('service'),

  @JsonValue('consultant')
  consultant('consultant');

  const AppointmentType(this.type);

  final String type;
}

enum OrderStatus {
  @JsonValue('new')
  neww('new'),
  @JsonValue('in_progress')
  inProgress('in_progress'),
  @JsonValue('delivering')
  delivering('delivering'),
  @JsonValue('completed')
  completed('completed'),
  @JsonValue('canceled')
  canceled('canceled'),
  @JsonValue('force_completed')
  forceCompleted('force_completed'),
  @JsonValue('confirmed')
  confirmed('confirmed'),
  @JsonValue('returned')
  returned('returned'),
  ;

  const OrderStatus(this.status);
  final String status;
}

@JsonEnum(valueField: 'id')
enum OrderBehavior {
  purchased('purchased'),
  returned('returned'),
  exchanged('exchanged'),
  ;

  const OrderBehavior(this.id);
  final String id;
}

extension OrderStatusExt on OrderStatus {
  bool get isNew => this == OrderStatus.neww;
  bool get isDelivering => this == OrderStatus.delivering;
  bool get isInProgress => this == OrderStatus.inProgress;
  bool get isCanceled => this == OrderStatus.canceled;
  bool get isCompleted => this == OrderStatus.completed;
  bool get isForceCompleted => this == OrderStatus.forceCompleted;
  bool get isConfirm => this == OrderStatus.confirmed;
  bool get isReturned => this == OrderStatus.returned;
  bool get isDelevering => this == OrderStatus.delivering;
}

enum CommentType {
  star1,
  star2,
  star3,
  star4,
  star5,
}

extension CommentTypeExt on CommentType {
  static String? toJson(CommentType? s) {
    return s?.type;
  }

  String get type {
    switch (this) {
      case CommentType.star1:
        return 'star_1';
      case CommentType.star2:
        return 'star_2';
      case CommentType.star3:
        return 'star_3';
      case CommentType.star4:
        return 'star_4';
      case CommentType.star5:
        return 'star_5';
    }
  }

  static CommentType? of(dynamic value) {
    final type = asOrNull<String>(value);
    for (final e in CommentType.values) {
      if (e.type == type) {
        return e;
      }
    }
    return null;
  }
}

enum DeliveryStatus {
  neww,
  confirmed,
  delivering,
  canceled,
  completed,
}

extension DeliveryStatusExt on DeliveryStatus {
  static String? toJson(DeliveryStatus? s) {
    return s?.type;
  }

  String get type {
    switch (this) {
      case DeliveryStatus.neww:
        return 'new';
      case DeliveryStatus.confirmed:
        return 'confirmed';
      case DeliveryStatus.delivering:
        return 'delivering';
      case DeliveryStatus.canceled:
        return 'canceled';
      case DeliveryStatus.completed:
        return 'completed';
    }
  }

  static DeliveryStatus? of(dynamic value) {
    final type = asOrNull<String>(value);
    for (final e in DeliveryStatus.values) {
      if (e.type == type) {
        return e;
      }
    }
    return null;
  }

  bool get isNew => this == DeliveryStatus.neww;
  bool get isConfirmed => this == DeliveryStatus.confirmed;
  bool get isCanceled => this == DeliveryStatus.canceled;
  bool get isCompleted => this == DeliveryStatus.completed;
  bool get isDelivering => this == DeliveryStatus.delivering;
}

@JsonEnum(valueField: 'id')
enum ProductTypeId {
  product('C'),
  service('service'),
  material('M'),
  combo('Cb'),
  ;

  const ProductTypeId(this.id);

  final String id;
}

extension ProductTypeExt on ProductTypeId {
  List<String> get filterIds {
    switch (this) {
      case ProductTypeId.product:
        return [
          ProductTypeId.product.id,
          ProductTypeId.combo.id,
        ];
      case ProductTypeId.service:
        return [
          ProductTypeId.service.id,
        ];
      case ProductTypeId.material:
        return [
          ProductTypeId.material.id,
        ];
      case ProductTypeId.combo:
        return [
          ProductTypeId.product.id,
          ProductTypeId.combo.id,
        ];
    }
  }
}

enum Behaviour {
  ratingComment,
  question,
}

extension BehaviourExt on Behaviour {
  static String? toJson(Behaviour? s) {
    return s?.type;
  }

  String get type {
    switch (this) {
      case Behaviour.ratingComment:
        return 'rating_comment';
      case Behaviour.question:
        return 'question';
    }
  }

  static Behaviour? of(dynamic value) {
    final type = asOrNull<String>(value);
    for (final e in Behaviour.values) {
      if (e.type == type) {
        return e;
      }
    }
    return null;
  }
}

class BehaviorID {
  static const before = 'before';
  static const after = 'after';
  static const document = 'document';
}

class TaskStatusID {
  static const done = 'done_branch';
  static const inProgress = 'inprogress_branch';
  static const neww = 'new_branch';
}

enum TaskPriorityID { urgent, high, medium, low }

extension TaskPriorityIDExt on TaskPriorityID {
  int get number {
    final map = TaskPriorityID.values.asMap().entries;
    return map.firstWhere((element) => element.value == this).key;
  }
}

enum WalletType {
  @JsonValue('VND')
  vnd('VND'),
  @JsonValue('COMMISSION')
  commission('COMMISSION'),
  @JsonValue('DP')
  point('DP'),
  @JsonValue('KPI')
  kpi('KPI'),
  @JsonValue('BP')
  bonusPoint('BP'),
  @JsonValue('VND_PROMOTION')
  promotion('VND_PROMOTION'),
  ;

  final String type;

  const WalletType(this.type);
}

@JsonEnum(valueField: 'id')
enum TransactionBehavior {
  refundDeposit('refund_deposit'),
  refundCollaborator('refund_collaborator'),
  refundOrder('refund_order'),
  commission('commission'),
  orderService('service'),
  orderProduct('order'),
  pointPayment('point_payment'),
  editPoint('edit_point'),
  deposit('deposit'),
  withdrawOnline('withdraw_online'),
  withdrawCash('withdraw_cash'),
  fundIncome('fund_income'),
  fundSpend('fund_spend'),
  otherIncome('other_income'),
  otherSpend('other_spend'),
  prioritizedGroupPoint('prioritized_group_point'),
  prioritizedGroupCommission('prioritized_group_commission'),
  refundPointPayment('refund_point_payment'),
  ;

  final String id;
  const TransactionBehavior(this.id);
}

enum TransactionType {
  all(null),
  @JsonValue('D')
  deposit('D'),
  @JsonValue('T')
  transfer('T'),
  @JsonValue('R')
  refund('R');

  final String? id;
  const TransactionType(this.id);
}

enum MembershipEnum {
  @JsonValue('br')
  member('br'),
  @JsonValue('si')
  silver('si'),
  @JsonValue('go')
  gold('go'),
  @JsonValue('rb')
  ruby('rb'),
  @JsonValue('dm')
  diamond('dm'),
  @JsonValue('kq')
  kingQueen('kq');

  const MembershipEnum(this.rank);

  final String rank;
}

enum CloudFileBehaviour {
  @JsonValue('certificate')
  certificate('certificate'),

  @JsonValue('contract')
  contract('contract'),

  @JsonValue('feature')
  feature('feature'),

  @JsonValue('layoff')
  layoff('layoff'),

  @JsonValue('other_benefit')
  otherBenefits('other_benefit'),

  @JsonValue('other_document')
  otherDocument('other_document'),

  @JsonValue('personal_income_tax')
  personalIncomeTax('personal_income_tax'),

  @JsonValue('regulation')
  regulation('regulation'),

  @JsonValue('result')
  result('result'),

  @JsonValue('sanction')
  sanction('sanction'),

  @JsonValue('social_insurance')
  socialInsurance('social_insurance'),

  @JsonValue('other_benefit')
  otherBenefit('other_benefit'),

  @JsonValue('clock_in')
  clockIn('clock_in'),

  @JsonValue('clock_out')
  clockOut('clock_out'),

  @JsonValue('unknow')
  unknow('unknow'),
  ;

  final String? type;

  const CloudFileBehaviour(this.type);
}

enum ApprovalBehaviourID {
  lateArrival('late_arrival'),
  earlyLeave('early_leave'),
  ;

  const ApprovalBehaviourID(this.id);

  final String id;
}

@JsonEnum(valueField: 'value')
enum PaymentMethodType {
  cash('cash'),
  card('card'),
  walletPromotionlver('wallet_promotion'),
  wallet('wallet'),
  bank('bank'),
  pointReturn('point_return'),
  pointPayment('point_payment'),
  ;

  const PaymentMethodType(this.value);

  final String value;
}

enum DiscountType {
  @JsonValue('amount')
  amount('đ'),
  @JsonValue('percent')
  percent('%'),
  ;

  const DiscountType(this.value);

  final String value;
}

@JsonEnum(valueField: 'type')
enum FundTypeID {
  income('income'),
  spend('spend');

  const FundTypeID(this.type);
  final String type;
}

@JsonEnum(valueField: 'id')
enum FundStatusType {
  completed('completed'),
  canceled('canceled');

  const FundStatusType(this.id);
  final String id;
}

@JsonEnum(valueField: 'id')
enum FundBehaviorType {
  importNcc('import_ncc'),
  returnNcc('return_ncc'),
  returnOrder('return_order'),
  orderIncome('order_income'),
  returnOrderIncome('return_order_income'),
  supplierSpend('supplier_spend');

  const FundBehaviorType(this.id);
  final String id;
}

extension FundStatusTypeLocalize on FundStatusType {
  Color get color {
    switch (this) {
      case FundStatusType.canceled:
        return const Color(0xFFDE5939);
      case FundStatusType.completed:
        return const Color(0xFF67C13C);
    }
  }

  Color get bgColor {
    return color.withAlpha(25);
  }
}

@JsonEnum(valueField: 'key')
enum ImportExportPriceSuggestion {
  lastImportPrice('last_import_price'),
  lastExportPrice('last_export_price'),
  capitalPrice('capital_price');

  final String key;
  const ImportExportPriceSuggestion(this.key);
}

@JsonEnum(valueField: 'type')
enum FundReferenceType {
  order('order'),
  supplier('supplier');

  const FundReferenceType(this.type);
  final String type;
}

@JsonEnum(valueField: 'type')
enum InventoryManagementType {
  import('import'),
  export('export'),
  check('check'),
  transfer('transfer'),
  transferReturn('transfer_return');

  const InventoryManagementType(this.type);
  final String type;
}

@JsonEnum(valueField: 'id')
enum InventoryDocumentStatusId {
  neww('new'),
  released('released'),
  canceled('canceled'),
  ;

  const InventoryDocumentStatusId(this.id);
  final String id;
}

@JsonEnum(valueField: 'id')
enum InventoryInvoiceStatus {
  canceled('canceled'),
  completed('completed'),
  ;

  const InventoryInvoiceStatus(this.id);
  final String id;
}

@JsonEnum(valueField: 'id')
enum InventoryRequestStatus {
  neww('new'),
  balanced('balanced'),
  canceled('canceled'),
  completed('completed'),
  delivering('delivering'),
  ;

  const InventoryRequestStatus(this.id);
  final String id;
}

@JsonEnum(valueField: 'type')
enum InventoryDocumentBehaviorType {
  order('order'),
  orderTransfer('order_transfer'),
  supplier('supplier'),
  inventoryCheck('inventory_check'),
  exportCancel('export_cancel'),
  debtSupplier('debt_supplier'),
  transferReturn('transfer_return');

  const InventoryDocumentBehaviorType(this.type);
  final String type;
}

@JsonEnum(valueField: 'type')
enum ProductSupplierStatus {
  inactive('inactive'),
  active('active');

  const ProductSupplierStatus(this.type);
  final String type;
}

@JsonEnum(valueField: 'type')
enum SearchCustomerStatus {
  inactive('inactive'),
  active('active');

  const SearchCustomerStatus(this.type);
  final String type;
}

@JsonEnum(valueField: 'type')
enum ExchangePointType {
  money('money'),
  gift('gift'),
  ;

  const ExchangePointType(this.type);
  final String type;
}

@JsonEnum(valueField: 'id')
enum BonusPointPaymentType {
  invoice('invoice'),
  product('product'),
  ;

  const BonusPointPaymentType(this.id);
  final String id;
}
