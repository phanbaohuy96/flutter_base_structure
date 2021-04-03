import 'package:flutter/material.dart';

class NotifyDialog extends StatelessWidget {
  final Text titlePopup;
  final Widget iconPopup;
  final Text content;
  final double height;
  final double width;
  final List<Widget> buttonActions;
  final Alignment alignment;

  NotifyDialog({
    Key key,
    this.titlePopup,
    this.iconPopup,
    this.content,
    this.width,
    this.height,
    this.buttonActions,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Container(
          height: height,
          width: width,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: iconPopup,
              ),
              const SizedBox(
                height: 10,
              ),
              if (titlePopup != null) titlePopup,
              if (titlePopup != null)
                const SizedBox(
                  height: 10,
                ),
              if (content != null) content,
              if (content != null)
                const SizedBox(
                  height: 20,
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: buttonActions,
              )
            ],
          ),
        ),
      ),
    );
  }
}
