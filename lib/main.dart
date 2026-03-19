import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/snackbar_helper.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/settings/presentation/bloc/printer_bloc.dart';
import 'features/settings/presentation/bloc/printer_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
            create: (context) => di.sl<ProductBloc>()..add(LoadProducts())),
        BlocProvider<ShopBloc>(
            create: (context) => di.sl<ShopBloc>()..add(LoadShopEvent())),
        BlocProvider<BillingBloc>(
            create: (context) =>
                BillingBloc(getProductByBarcodeUseCase: di.sl())),
        BlocProvider<PrinterBloc>(
            create: (context) => di.sl<PrinterBloc>()..add(InitPrinterEvent())),
        // Theme management Cubit
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit()
            ..loadFromPersistence(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(builder: (context, mode) {
        return MaterialApp.router(
          title: 'Mobile POS',
          // Keep the base themes from AppTheme but inject our global SnackBar style
          theme: AppTheme.lightTheme.copyWith(
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: StadiumBorder(),
              backgroundColor: Color(0xFFD32F2F), // default error red
              elevation: 6.0,
              contentTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: StadiumBorder(),
              backgroundColor: Color(0xFFD32F2F),
              elevation: 6.0,
              contentTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
          ),
          themeMode: mode,
          // Use global scaffold messenger key so the helper can show snackbars
          scaffoldMessengerKey: scaffoldMessengerKey,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}

