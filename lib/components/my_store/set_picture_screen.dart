import 'dart:math';
import 'dart:typed_data';

import 'package:butter/components/photo/photo_selector.dart';
import 'package:butter/main.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/state/me/me_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:redux/redux.dart';
import 'package:tuple/tuple.dart';

class SetPictureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (Store<AppState> store) => _Props.fromStore(store),
      builder: (context, props) {
        return _Presenter(setCoverImage: props.setCoverImage, myStoreId: props.myStoreId);
      },
    );
  }
}

class _Presenter extends StatefulWidget {
  final Function setCoverImage;
  final int myStoreId;

  _Presenter({Key key, this.setCoverImage, this.myStoreId}) : super(key: key);

  @override
  _PresenterState createState() => _PresenterState();
}

class _PresenterState extends State<_Presenter> {
  Asset _image;
  Uint8List _imageData;
  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              _appBar(),
              _form(),
            ],
          ),
        ),
        if (_showOverlay) _UploadOverlay(image: _image, myStoreId: widget.myStoreId, setCoverImage: widget.setCoverImage)
      ],
    );
  }

  Widget _appBar() {
    return SliverSafeArea(
      sliver: SliverToBoxAdapter(
          child: Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 35.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(width: 50.0, height: 60.0),
                Positioned(left: -12.0, child: BackArrow(color: Burnt.lightGrey)),
              ],
            ),
            Text('SET STORE PICTURE', style: Burnt.appBarTitleStyle)
          ],
        ),
      )),
    );
  }

  Widget _form() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 30.0, left: 16.0, right: 16.0),
            child: PhotoSelector(
              images: _imageData != null ? [_imageData] : [],
              onSelectImages: _loadImages,
              max: 1,
              addText: 'Select Photo',
              changeText: 'Change Photo',
            ),
          ),
          _buttons(),
          Container(height: 50.0),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Builder(builder: (context) {
      return Container(
        padding: EdgeInsets.only(bottom: 30.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Burnt.primary,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(2.0)),
              padding: EdgeInsets.symmetric(vertical: 11.0, horizontal: 16.0),
              child: Text('CANCEL', style: TextStyle(fontSize: 16.0, color: Burnt.primary, letterSpacing: 3.0)),
            ),
          ),
          Container(width: 8.0),
          InkWell(
            onTap: () => _submit(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                gradient: Burnt.burntGradient,
              ),
              child: Text('SUBMIT', style: TextStyle(fontSize: 16.0, color: Colors.white, letterSpacing: 3.0)),
            ),
          ),
        ]),
      );
    });
  }

  _submit(context) {
    if (_image == null) {
      snack(context, 'Select a photo first');
      return;
    } else if (_image.originalHeight > 5000 || _image.originalWidth > 5000) {
      snack(context, 'Oops! Photo has to be smaller than 5000x5000');
    }
    if (_image != null) setState(() => _showOverlay = true);
  }

  _loadImages(photos) async {
    var image = photos[0];
    var byteData = await image.getByteData(quality: 80);
    this.setState(() {
      _image = image;
      _imageData = byteData.buffer.asUint8List();
    });
  }
}

class _Props {
  final Function setCoverImage;
  final int myStoreId;

  _Props({this.setCoverImage, this.myStoreId});

  static fromStore(Store<AppState> store) {
    return _Props(
      setCoverImage: (picture) {
        store.dispatch(SetCoverImage(picture));
      },
      myStoreId: store.state.me.store?.id,
    );
  }
}

class _UploadOverlay extends StatefulWidget {
  final Asset image;
  final int myStoreId;
  final Function setCoverImage;

  _UploadOverlay({Key key, this.image, this.myStoreId, this.setCoverImage}) : super(key: key);

  @override
  _UploadOverlayState createState() => _UploadOverlayState();
}

class _UploadOverlayState extends State<_UploadOverlay> {
  String _error;

  @override
  initState() {
    super.initState();
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x99000000),
      body: Center(
        child: AlertDialog(content: _content()),
      ),
    );
  }

  Widget _content() {
    if (_error != null) return Text(_error);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(height: 15.0),
        Container(
          width: 50.0,
          height: 50.0,
          child: CircularProgressIndicator(),
        ),
        Container(height: 20.0),
        Text('Uploading your awesome photo…'),
      ],
    );
  }

  _submit() async {
    String url = await _uploadPhoto();
    if (url == null) {
      this.setState(() => _error = 'Oops! Something went wrong, please try again');
      return;
    }

    var result = await MeService.setCoverImage(storeId: widget.myStoreId, pictureUrl: url);
    if (result != true) {
      setState(() => _error = 'Oops! Something went wrong, please try again.');
      return;
    }

    widget.setCoverImage(url);
    Navigator.popUntil(context, ModalRoute.withName(MainRoutes.home));
    Navigator.pushReplacementNamed(context, MainRoutes.home);
    return;
  }

  Future<String> _uploadPhoto() async {
    String timestamp = '${DateTime.now().millisecondsSinceEpoch}';
    Uint8List byteData = await _getByteData(widget.image);
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    if (user == null) await auth.signInAnonymously();
    String fileName = '$timestamp-${Random().nextInt(10000)}.jpg';
    StorageReference ref = FirebaseStorage.instance.ref().child('stores/cover-image/$fileName');
    Tuple2<StorageUploadTask, StorageReference> task =
        Tuple2(ref.putData(byteData, StorageMetadata(contentType: "image/jpeg", customMetadata: {'secret': 'breadcat'})), ref);
    await task.item1.onComplete;
    if (task.item1.isSuccessful) {
      return await task.item2.getDownloadURL();
    }
    return null;
  }

  Future<Uint8List> _getByteData(Asset asset) async {
    ByteData byteData = await asset.getByteData();
    List<int> compressed = await FlutterImageCompress.compressWithList(
      byteData.buffer.asUint8List(),
      minWidth: 1080,
    );
    return Uint8List.fromList(compressed);
  }
}
