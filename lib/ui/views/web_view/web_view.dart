import 'dart:async';
import 'package:FSOUNotes/models/notes.dart';
import 'package:FSOUNotes/ui/views/web_view/web_view_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class WebViewWidget extends StatefulWidget {
  Note note;
  WebViewWidget({this.note, Key key}) : super(key: key);

  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  // Instance of WebView plugin
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // On destroy stream
  StreamSubscription _onDestroy;

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  final _history = [];

  WebViewModel localModel;

  @override
  void initState() {
    super.initState();
    flutterWebViewPlugin.close();

    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        if ((url.contains("export=download") ||
                url.contains("docs.googleusercontent.com/")) &&
            localModel != null) {
          localModel.showDownloadPreventDialog(flutterWebViewPlugin);
        }
        setState(() {
          _history.add('onUrlChanged: $url');
        });
      }
    });
  }

  @override
  void dispose() {
    flutterWebViewPlugin.dispose();
    _onUrlChanged.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //* Since The app bar is a bit annoying when in landscape
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return ViewModelBuilder.reactive(
        onModelReady: (model) => localModel = model,
        builder: (context, model, child) {
          return new WebviewScaffold(
            initialChild: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Loading ....",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        fontSize: 25),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            ),
            hidden: true,
            url: widget.note.GDriveLink,
            appBar: isLandscape
                ? null
                : new AppBar(
                    iconTheme: IconThemeData(
                      color: Colors.white, //change your color here
                    ),
                    title: new Text("Notes"),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {
                          //TODO add share text
                          final RenderBox box = context.findRenderObject();
                          Share.share(
                              "Notes Name: ${widget.note.title}\n\nSubject Name: ${widget.note.subjectName}\n\nLink:${widget.note.GDriveLink}\n\nFind Latest Notes | Question Papers | Syllabus | Resources for Osmania University at the OU NOTES App\n\nhttps://play.google.com/store/apps/details?id=com.notes.ounotes",
                              sharePositionOrigin:
                                  box.localToGlobal(Offset.zero) & box.size);
                        },
                      )
                    ],
                  ),
          );
        },
        viewModelBuilder: () => WebViewModel());
  }
}
