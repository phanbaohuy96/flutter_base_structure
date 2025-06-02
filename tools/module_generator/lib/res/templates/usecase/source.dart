import 'templates/detail_usecase.dart';
import 'templates/listing_usecase.dart';
import 'templates/usecase.dart';

final usecaseRes = {
  'common': {'usecase': usecase, 'usecase.impl': usecaseImpl},
  'listing': {'usecase': listingUsecase, 'usecase.impl': listingUsecaseImpl},
  'detail': {'usecase': detailUsecase, 'usecase.impl': detailUsecaseImpl},
};
