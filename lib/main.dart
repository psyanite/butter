import 'package:butter/components/screens/home_screen.dart';
import 'package:butter/components/screens/login_screen.dart';
import 'package:butter/components/screens/splash_screen.dart';
import 'package:butter/presentation/platform_adaptive.dart';
import 'package:butter/state/app/app_middleware.dart';
import 'package:butter/state/app/app_reducer.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:redux_thunk/redux_thunk.dart';

main() async {
  final persistor = Persistor<AppState>(storage: FlutterStorage(key: 'butter'), serializer: JsonSerializer<AppState>(AppState.rehydrate));

  var initialState;
  try {
    initialState = await persistor.load();
  } catch (e) {
    initialState = null;
  }

  List<Middleware<AppState>> createMiddleware() {
    return <Middleware<AppState>>[
      thunkMiddleware,
      persistor.createMiddleware(),
      LoggingMiddleware.printer(),
      ...createAppMiddleware(),
    ];
  }

  final store = Store<AppState>(
    appReducer,
    initialState: initialState ?? AppState(),
    middleware: createMiddleware(),
  );

  runApp(Main(store: store));
}

class MainRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
}

class Main extends StatelessWidget {
  final store;

  Main({this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Burntoast Promote',
        color: Color(0xFFF2993E),
        theme: getTheme(context),
        initialRoute: MainRoutes.splash,
        routes: <String, WidgetBuilder>{
          MainRoutes.splash: (context) => SplashScreen(),
          MainRoutes.login: (context) => LoginScreen(),
          MainRoutes.home: (context) => HomeScreen(),
        },
      ),
    );
  }
}
