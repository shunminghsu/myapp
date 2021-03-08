import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'ad_state.dart';
import 'data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);
  runApp(
    Provider.value(
      value: adState,
      builder: (context, child) => MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: JokeListScreen(defaultJokeList),
    );
  }
}

class JokeListScreen extends StatefulWidget {
  final List<Joke> jokes;

  JokeListScreen(this.jokes);

  @override
  _JokeListScreenState createState() => _JokeListScreenState();
}

class _JokeListScreenState extends State<JokeListScreen> {
  List<Object> itemList;
  Banner banner;

  @override
  void initState() {
    super.initState();
    itemList = List.from(widget.jokes);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((status) {
      setState(() {
        for (int i = itemList.length - 2; i >= 1; i -= 10) {
          itemList.insert(
            i,
            BannerAd(
              adUnitId: adState.bannerAdUnitId,
              size: AdSize.banner,
              request: AdRequest(),
              listener: adState.adListener,
            )..load(),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My test app'),
      ),
      body: ListView.builder(
        itemBuilder: (context, i) {
          if (itemList[i] is Joke) {
            return JokeRow(itemList[i] as Joke);
          } else {
            return Container(
              height: 50,
              color: Colors.black,
              child: AdWidget(ad: itemList[i] as BannerAd),
            );
          }
        },
        itemCount: itemList.length,
      )
    );
  }
}

class JokeRow extends StatelessWidget {
  final Joke item;
  JokeRow(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.title),
      subtitle: Text(item.text),
    );
  }
}