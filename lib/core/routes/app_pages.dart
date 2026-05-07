import 'package:get/get.dart';

import '../../features/history/presentation/item_detail_page.dart';
import 'app_router.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: AppRouter.new,
    ),
    GetPage<dynamic>(
      name: AppRoutes.itemDetail,
      page: ItemDetailPage.fromRoute,
    ),
  ];
}
