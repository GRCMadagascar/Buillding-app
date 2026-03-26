import 'package:go_router/go_router.dart';
import '../../features/billing/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/billing/presentation/pages/sales_history_page.dart';
import '../../features/billing/presentation/pages/scanner_page.dart';
import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/billing/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard.dart';
import '../../core/widgets/no_access_page.dart';
import '../../core/services/current_user_service.dart';
import '../../core/models/user_role.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'scanner',
          builder: (context, state) => const ScannerPage(),
        ),
        GoRoute(
          path: 'checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/verify',
      builder: (context, state) => const EmailVerificationPage(),
    ),
    GoRoute(
      path: '/sales_history',
      builder: (context, state) => const SalesHistoryPage(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) {
        // Both admins and vendeurs can access product list
        final role = CurrentUserService.role;
        if (role == null) return const NoAccessPage();
        return const ProductListPage();
      },
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) {
            final role = CurrentUserService.role;
            if (role == UserRole.vendeur) {
              return const NoAccessPage(
                  message: 'Ajout de produit réservé aux administrateurs');
            }
            return const AddProductPage();
          },
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final product = state.extra as Product?;
            if (product == null) {
              // If we land here without extra (e.g. deep link), go back to products for now.
              return const ProductListPage();
            }
            return EditProductPage(product: product);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopDetailsPage(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),
  ],
);
