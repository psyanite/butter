import 'package:butter/models/post.dart';
import 'package:butter/presentation/crust_cons_icons.dart';
import 'package:butter/presentation/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SolidBackButton extends StatelessWidget {
  final Color color;
  final Color textColor;

  SolidBackButton({Key key, this.color = Burnt.primary, this.textColor = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: EdgeInsets.only(left: 7.0, right: 13.0, top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2.0)), color: color),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(Icons.arrow_back_ios, color: textColor, size: 20.0),
          Container(width: 3.0),
          Text('Go Back', style: TextStyle(color: textColor, fontSize: 22.0))
        ]),
      ),
    );
  }
}

class WhiteBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SolidBackButton(color: Colors.white, textColor: Burnt.primary);
  }
}

class BackArrow extends StatelessWidget {
  final Color color;
  final Function onTap;

  BackArrow({Key key, this.color = Burnt.textBodyColor, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(CrustCons.back, color: color, size: 30.0),
      onPressed: () => onTap != null ? onTap(context) : Navigator.of(context).pop(),
    );
  }
}

class SmallButton extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final EdgeInsetsGeometry padding;
  final Gradient gradient;
  final Color color;

  SmallButton({
    Key key,
    this.child,
    this.onTap,
    this.padding,
    this.gradient = Burnt.splashGradientDuo,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
          gradient: color != null ? null : gradient,
          color: color,
        ),
        child: child,
      ),
    );
  }
}

class SmallSolidButton extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final EdgeInsetsGeometry padding;
  final Color color;

  SmallSolidButton({
    Key key,
    this.child,
    this.onTap,
    this.padding,
    this.color = Burnt.splashButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2.0)), color: color),
        child: child,
      ),
    );
  }
}

class WhiteButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Function onPressed;

  WhiteButton({Key key, this.text, this.textColor = Burnt.primary, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: Burnt.primaryLight,
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
            boxShadow: [BoxShadow(color: Color(0x10000000), offset: Offset(5.0, 5.0), blurRadius: 10.0, spreadRadius: 1.0)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(text, style: TextStyle(fontSize: 20.0, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  BottomButton({Key key, this.text, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
          gradient: Burnt.buttonGradient,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(text, style: TextStyle(fontSize: 20.0, color: Colors.white, letterSpacing: 3.0)),
          ],
        ),
      ),
    );
  }
}

class BurntButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String text;
  final Function onPressed;
  final double padding;
  final double fontSize;

  BurntButton({Key key, this.icon, this.iconSize, this.text, this.onPressed, this.padding, this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: padding ?? 20.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
            gradient: Burnt.splashGradientDuo),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (icon != null) Icon(icon, size: iconSize ?? 20.0, color: Colors.white),
            if (icon != null) Container(width: 8.0),
            Text(text, style: TextStyle(fontSize: fontSize ?? 22.0, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class SolidButton extends StatelessWidget {
  final Function onTap;
  final List<Widget> children;
  final EdgeInsets padding;
  final Color color;
  final Color splashColor;

  SolidButton({Key key, this.onTap, this.children, this.padding, this.color, this.splashColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: splashColor ?? Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          borderRadius: BorderRadius.circular(2.0),
        ),
        padding: padding ?? EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}

class HollowButton extends StatelessWidget {
  final Function onTap;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color splashColor;

  HollowButton({Key key, this.onTap, this.children, this.padding, this.borderColor, this.splashColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: splashColor ?? Burnt.splashOrange,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Color(0xFFFFD173), width: 1.0, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(2.0),
        ),
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}

class LoadingCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class SliverCenter extends StatelessWidget {
  final Widget child;

  SliverCenter({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Container(
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

class LoadingSliverCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverCenter(
      child: CircularProgressIndicator(),
    );
  }
}

class LoadingSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Container(height: 200, child: Center(child: CircularProgressIndicator())));
  }
}

class CenterTextSliver extends StatelessWidget {
  final String text;

  CenterTextSliver({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 50.0),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 17.0), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class ScoreIcon extends StatelessWidget {
  final double opacity;
  final Score score;
  final double size;
  final String name;

  ScoreIcon({Key key, this.score, this.size = 25.0, this.name, this.opacity = 1.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var assetName;
    switch (score) {
      case (Score.bad):
        {
          assetName = 'assets/svgs/bread-bad.svg';
        }
        break;
      case (Score.okay):
        {
          assetName = 'assets/svgs/bread-okay.svg';
        }
        break;
      case (Score.good):
        {
          assetName = 'assets/svgs/bread-good.svg';
        }
        break;
      default:
        {
          return new Container();
        }
    }
    return Column(children: <Widget>[
      Opacity(
        key: UniqueKey(),
        opacity: opacity,
        child: SvgPicture.asset(
          assetName,
          key: UniqueKey(),
          width: size,
          height: size,
        ),
      ),
      if (name != null) _name()
    ]);
  }

  Widget _name() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Text(name),
    );
  }
}

class HeartIcon extends StatelessWidget {
  final bool isHollow;
  final double size;

  HeartIcon({Key key, this.isHollow, this.size = 25.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var assetName = isHollow ? 'assets/svgs/heart-hollow.svg' : 'assets/svgs/heart-filled.svg';
    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
    );
  }
}

class NetworkImg extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BoxFit fit;

  NetworkImg(this.url, {Key key, this.width, this.height, this.padding, this.margin, this.fit = BoxFit.cover}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url == null || url.isEmpty) {
      return Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        color: Burnt.imgPlaceholderColor,
      );
    }
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: Burnt.imgPlaceholderColor,
        image: DecorationImage(image: CachedNetworkImageProvider(url), fit: BoxFit.cover),
      ),
    );
  }
}

snack(context, text) {
  final snackBar = SnackBar(
    content: Text(text),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {},
    ),
  );
  Scaffold.of(context).showSnackBar(snackBar);
}
