import 'package:get/get.dart';
import 'package:mcap_orders_app/app/modules/add_order/add_order_binding.dart';
import 'package:mcap_orders_app/app/modules/add_order/add_order_page.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/add_outlet/add_outlet_binding.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/add_outlet/add_outlet_page.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/add_user/add_user_binding.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/add_user/add_user_page.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/admin_home/admin_home.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/all_items/all_items_binding.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/all_items/all_items_page.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/all_outlets/all_outlets_binding.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/all_outlets/all_outlets_page.dart';
import 'package:mcap_orders_app/app/modules/auth/auth_binding.dart';
import 'package:mcap_orders_app/app/modules/auth/auth_page.dart';
import 'package:mcap_orders_app/app/modules/my_outlets/my_outlets_binding.dart';
import 'package:mcap_orders_app/app/modules/my_outlets/my_outlets_page.dart';
import 'package:mcap_orders_app/app/modules/new_orders/new_orders_binding.dart';
import 'package:mcap_orders_app/app/modules/new_orders/new_orders_page.dart';
import 'package:mcap_orders_app/app/modules/orders_history/orders_history_binding.dart';
import 'package:mcap_orders_app/app/modules/orders_history/orders_history_page.dart';
import 'package:mcap_orders_app/app/modules/reports_history/reports_history_binding.dart';
import 'package:mcap_orders_app/app/modules/reports_history/reports_history_page.dart';
import 'package:mcap_orders_app/app/modules/settings/settigns_binding.dart';
import 'package:mcap_orders_app/app/modules/settings/settings_page.dart';

import 'app_routes.dart';

class AppPages {
  static const String INIT_PAGE = Routes.HOME_or_AUTH;
  static List<GetPage> get pages => [
        GetPage(
          name: Routes.HOME_or_AUTH,
          page: () => const AuthPage(),
          binding: AuthBinding(),
          transition: Transition.topLevel,
        ),
        GetPage(
          name: Routes.ADD_ORDER,
          page: () => const AddOrderPage(),
          binding: AddOrderBinding(),
          transition: Transition.topLevel,
        ),
        GetPage(
          name: Routes.ORDERS_HISTORY,
          page: () => const OrdersHistoryPage(),
          binding: OrdersHistoryBinding(),
        ),
        GetPage(
          name: Routes.REPORTS_HISTORY,
          page: () => const ReportsHistoryPage(),
          binding: ReportsHistoryBinding(),
        ),
        GetPage(
          name: Routes.MY_OUTLETS,
          page: () => const MyOutletsPage(),
          binding: MyOutletsBinding(),
        ),

        GetPage(
          name: Routes.SETTINGS,
          page: () => const SettingsPage(),
          binding: SettingsBinding(),
        ),

        //*************************** Admin Pages ***************************//

        GetPage(
          name: Routes.NEW_ORDERS,
          page: () => const NewOrdersPage(),
          binding: NewOrdersBinding(),
        ),

        GetPage(
          name: Routes.ADMIN_HOME,
          page: () => const AdminHomePage(),
        ),
        GetPage(
          name: Routes.ADMIN_GENERAL_OUTLETS,
          page: () => const AdminAllOutlets(),
          binding: AllOutletsBinding(),
        ),
        GetPage(
          name: Routes.ADMIN_CUSTOMER_OUTLETS,
          page: () => const AdminAllOutlets(isGeneral: false),
          binding: AllOutletsBinding(),
          arguments: const {"isGeneral": false},
        ),
        GetPage(
          name: Routes.ADMIN_ALL_ITEMS,
          page: () => const AdminAllItems(),
          binding: AllItemsBinding(),
        ),
        GetPage(
            name: Routes.ADMIN_NEW_OUTLET,
            page: () => const NewOutletPage(),
            binding: NewOutletBinding(),
            arguments: const {"isEdit": false}),
        GetPage(
          name: Routes.ADMIN_NEW_USER,
          page: () => const NewUserPage(),
          binding: NewUserBinding(),
        ),
      ];
}
