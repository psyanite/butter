import 'dart:typed_data';

import 'package:butter/components/new_post/upload_overlay.dart';
import 'package:butter/components/photo/photo_selector.dart';
import 'package:butter/models/post.dart';
import 'package:butter/models/store.dart' as MyStore;
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'current_photos.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  EditPostScreen({Key key, this.post}) : super(key: key);

  @override
  _PresenterState createState() => _PresenterState(currentPost: post);
}

class _PresenterState extends State<EditPostScreen> {
  final Post currentPost;
  MyStore.Store _store;
  Post _post;
  List<PostPhoto> _currentPhotos;
  List<Asset> _images = List<Asset>();
  List<Uint8List> _imageData = List<Uint8List>();
  List<PostPhoto> _deletePhotosQueue = List<PostPhoto>();
  bool _showUploadOverlay = false;
  TextEditingController _bodyCtrl = TextEditingController();

  _PresenterState({this.currentPost});

  @override
  initState() {
    super.initState();
    var review = currentPost.postReview;
    _store = currentPost.store;
    _currentPhotos = [...currentPost.postPhotos];
    if (review.body != null) _bodyCtrl = TextEditingController.fromValue(TextEditingValue(text: review.body));
  }

  @override
  dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Scaffold(
          body: Builder(
            builder: (context) {
              return CustomScrollView(
                slivers: <Widget>[
                  _appBar(context),
                  if (_currentPhotos.isNotEmpty) CurrentPhotos(photos: _currentPhotos, onPhotoDelete: removePhoto),
                  _photoSelector(context),
                  _reviewBody(context),
                  _buttons(context),
                ],
              );
            },
          ),
        ),
        if (_showUploadOverlay) UploadOverlay(post: _post, images: _images, deletePhotosQueue: _deletePhotosQueue),
      ],
    );
  }

  Widget _appBar(BuildContext context) {
    return SliverSafeArea(
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 40.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('EDIT REVIEW', style: Burnt.appBarTitleStyle),
                  Container(height: 50, width: 50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoSelector(BuildContext context) {
    var addPhotosButtonText = _currentPhotos.isEmpty ? 'Add Photos' : 'Add More Photos';
    Function(List<Asset>) onSelectImages = (photos) {
      setState(() {
        _images = photos;
        _imageData = List.generate(photos.length, (i) => null, growable: false);
      });
      _loadImages(photos);
    };
    return SliverPadding(
      padding: EdgeInsets.only(top: 20.0, right: 16.0, bottom: 30.0, left: 16.0),
      sliver: SliverToBoxAdapter(
        child: PhotoSelector(images: _imageData, onSelectImages: onSelectImages, addText: addPhotosButtonText),
      ),
    );
  }

  Widget _reviewBody(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(bottom: 30.0),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300.0,
              child: TextField(
                controller: _bodyCtrl,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Add your thoughts here',
                  hintStyle: TextStyle(color: Burnt.hintTextColor),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Burnt.lightGrey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Burnt.primaryLight, width: 1.0)),
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  bool _isValid(BuildContext context) {
    if ((_bodyCtrl.text == null || _bodyCtrl.text.isEmpty) && _images.isEmpty) {
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
        return "Oops! The photo is larger than 5000x5000";
      } else {
        return "Oops! One of the photos is larger than 5000x5000";
      }
    }
    return null;
  }

  Future<void> _submit(BuildContext context) async {
    if (!_isValid(context)) return false;

    var newPost = Post(
      id: currentPost.id,
      type: PostType.review,
      store: _store,
      postPhotos: [],
      postReview: PostReview(
        body: _bodyCtrl.text,
      ),
    );

    setState(() {
      _post = newPost;
      _showUploadOverlay = true;
    });
  }

  Widget _buttons(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(bottom: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[Text('CANCEL', style: TextStyle(fontSize: 16.0, color: Burnt.primary, letterSpacing: 3.0))],
                ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[Text('SUBMIT', style: TextStyle(fontSize: 16.0, color: Colors.white, letterSpacing: 3.0))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  removePhoto(PostPhoto photo) {
    _currentPhotos.removeWhere((p) => p.id == photo.id);
    _deletePhotosQueue.add(photo);
  }

  _loadImages(List<Asset> photos) async {
    _images.asMap().forEach((i, image) async {
      var byteData = await image.getByteData(quality: 80);
      _imageData[i] = byteData.buffer.asUint8List();
      setState(() {
        _imageData = _imageData;
      });
    });
  }
}
