import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:frontend/settings.dart';

class Switcher extends StatefulWidget {
  static final double width = dailyAttendanceSettings["widget.switcher.width"];
  static final double height = dailyAttendanceSettings["widget.switcher.height"];
  static final double buttonWidth = dailyAttendanceSettings["widget.switcher.button.width"];
  static final double buttonHeight = dailyAttendanceSettings["widget.switcher.button.height"];
  static final double startLeft = 0;

  static Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    double halfWidth = size.width / 2;
    double externalRadius = halfWidth;
    double internalRadius = halfWidth / 2.5;
    double degreesPerStep = degToRad(360 / numberOfPoints);
    double halfDegreesPerStep = degreesPerStep / 2;
    Path path = Path();
    double fullAngle = degToRad(360);
    path.moveTo(size.width, size.height);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  SwitcherController controller;
  void Function(bool) onChanged;

  Switcher({required this.controller, required this.onChanged});

  @override
  _SwitcherState createState() => _SwitcherState();
}

class _SwitcherState extends State<Switcher> {
  bool get value => widget.controller.value;
  late ConfettiController controller;
  double left = 0;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() async {
      setState(() {
        debugPrint("setState called on switcher");
        if (value) {
          left = Switcher.width - Switcher.height;
          controller.play();
        } else {
          left = Switcher.startLeft;
          controller.stop();
        }
      });

      if (value) {
        await Future.delayed(const Duration(seconds: 3));
      }

      setState(() {
        isVisible = !value;
      });
    });
    controller = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (value) {
      left = Switcher.width - Switcher.height;
    } else {
      left = Switcher.startLeft;
    }

    return isVisible ? Offstage(
      offstage: !isVisible,
      child: Stack(
        alignment: Alignment.center,
        children: [
          buildButton(context),
          ConfettiWidget(
            confettiController: controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],

            createParticlePath: Switcher.drawStar,
          )
        ],
      ),
    ) : SizedBox(height: Switcher.buttonHeight,);
  }
  
  Widget buildButton(BuildContext context) {
    final Widget button = Container(
      width: Switcher.buttonWidth,
      height: Switcher.buttonHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
            color: Color.fromRGBO(0, 0, 0, 0.3)
          )
        ]
      ),
      
      child: const Center(child: Icon(Icons.check, color: Color.fromRGBO(0, 0, 0, 0.3),),),
    );
    
    return StatefulBuilder(builder: (context, setState) => Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1, microseconds: 500),
          width: Switcher.width,
          height: Switcher.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(Switcher.height / 2)),
            color: value ? Colors.transparent : const Color.fromRGBO(0, 0, 0, 0.1)
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(seconds: 1, microseconds: 500),
          left: left,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              widget.controller.value = !value;
              widget.onChanged(value);
            },

            child: button,
          ),
        )
      ],
    ));
  }
}

class SwitcherController extends ChangeNotifier {
  bool? _value;
  bool get value => _value!;
  set value(bool value) {
    _value = value;
    notifyListeners();
  }

  SwitcherController({required bool value}) {
    this.value = value;
  }
}