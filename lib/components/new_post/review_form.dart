import 'dart:typed_data';

import 'package:butter/components/new_post/upload_overlay.dart';
import 'package:butter/components/photo/photo_selector.dart';
import 'package:butter/models/admin.dart';
import 'package:butter/models/post.dart';
import 'package:butter/models/store.dart' as MyStore;
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:redux/redux.dart';

class ReviewForm extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _Props>(
      converter: (Store<AppState> store) => _Props.fromStore(store),
      builder: (BuildContext context, _Props props) {
        return _Presenter(
          store: props.store,
          me: props.me,
        );
      },
    );
  }
}

class _Presenter extends StatefulWidget {
  final MyStore.Store store;
  final Admin me;

  _Presenter({Key key, this.store, this.me}) : super(key: key);

  @override
  _PresenterState createState() => _PresenterState();
}

class _PresenterState extends State<_Presenter> {
  Post _post;
  String _reviewBody;
  List<Asset> _images = List<Asset>();
  List<Uint8List> _imageData = List<Uint8List>();
  bool _showOverlay = false;

  _PresenterState();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Scaffold(
          body: ListView(
            children: <Widget>[
              _appBar(),
              _content(),
            ],
          ),
        ),
        if (_showOverlay) UploadOverlay(post: _post, images: _images)
      ],
    );
  }

  Widget _appBar() {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 40.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('NEW POST', style: Burnt.appBarTitleStyle),
              Container(height: 50, width: 50),
            ],
          ),
        ],
      ),
    );
  }

  Widget _content() {
    Function(List<Asset>) onSelectImages = (photos) {
      setState(() {
        _images = photos;
        _imageData = List.generate(photos.length, (i) => null, growable: false);
      });
      _loadImages(photos);
    };
    return Builder(builder: (context) {
      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
                child: PhotoSelector(images: _imageData, onSelectImages: onSelectImages),
              ),
              _body(),
            ]),
          ),
          _buttons(context),
        ],
      );
    });
  }

  Widget _body() {
    return Container(
      width: 300.0,
      padding: EdgeInsets.only(bottom: 30.0),
      child: TextField(
        maxLines: null,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.multiline,
        onChanged: (text) => setState(() => _reviewBody = text),
        decoration: InputDecoration(
          hintText: 'Add your thoughts here',
          hintStyle: TextStyle(color: Burnt.hintTextColor),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Burnt.lightGrey)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Burnt.primaryLight, width: 1.0)),
        ),
      ),
    );
  }

  bool _isValid(BuildContext context) {
    if ((_reviewBody == null || _reviewBody.isEmpty) && _images.isEmpty) {
      snack(context, "Add some photos or add some thoughts");
      return false;
    }
    if (_images.isNotEmpty) {
      var validatePhotos = _validatePhotos();
      if (validatePhotos != null) {
        snack(context, validatePhotos);
        return false;
      }
    }
    return true;
  }

  String _validatePhotos() {
    var isValid = true;
    _images.forEach((a) {
      if (a.originalHeight > 5000 || a.originalWidth > 5000) {
        isValid = false;
        return;
      }
    });
    if (!isValid) {
      if (_images.length == 1) {
        return "Oops! Photo has to be smaller than 5000x5000";
      } else {
        return "Oops! All the photos have to be smaller than 5000x5000";
      }
    }
    return null;
  }

  _submit(BuildContext context) async {
    if (!_isValid(context)) return false;

    var newPost = Post(
      type: PostType.review,
      store: widget.store,
      postPhotos: [],
      postReview: PostReview(
        body: _reviewBody,
      ),
      postedByAdmin: widget.me,
    );

    setState(() {
      _post = newPost;
      _showOverlay = true;
    });
  }

  Widget _buttons(BuildContext context) {
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
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                stops: [0, 0.6, 1.0],
                colors: [Color(0xFFFFAB40), Color(0xFFFFAB40), Color(0xFFFFC86B)],
              ),
            ),
            child: Text('SUBMIT', style: TextStyle(fontSize: 16.0, color: Colors.white, letterSpacing: 3.0)),
          ),
        ),
      ]),
    );
  }

  _loadImages(photos) async {
    _images.asMap().forEach((i, image) async {
      var byteData = await image.getByteData(quality: 80);
      _imageData[i] = byteData.buffer.asUint8List();
      setState(() {
        _imageData = _imageData;
      });
    });
  }
}

class _Props {
  final MyStore.Store store;
  final Admin me;

  _Props({
    this.store,
    this.me,
  });

  static fromStore(Store<AppState> store) {
    return _Props(
      store: store.state.me.store,
      me: store.state.me.admin,
    );
  }
}
