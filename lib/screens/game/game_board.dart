import 'dart:developer';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/constants.dart';
import '../../widgets/flip_animation.dart';
import '../../widgets/game_end_widget.dart';
import '../../widgets/player_widget.dart';
//Song: My Mind goes salalalala

class GameBoard extends StatefulWidget {
  final List<String> players;
  final AudioPlayer bgm;

  const GameBoard({
    super.key,
    required this.bgm,
    required this.players,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  List<FlipController> flipController = [];
  List twoTaps = [];
  List twoTapsElement = [];
  List totalItems = [];
  final random = math.Random();
  dynamic images;
  int playerIndex = 0;
  List<int> playerScoreList = [];

  List<Color> bgColor = [];
  late AnimationController colorAnimation;
  late Animation<double> animation;
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();
    images = listOfItems..shuffle();
    _setInitialScore();
    setPlayerBgColor();
    flipController.clear();
    flipController = List.generate(listOfItems.length, (i) => FlipController());
    colorAnimation = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation = Tween<double>(
      begin: 0,
      end: 30 * math.pi,
    ).animate(colorAnimation)
      ..addListener(() {});
    // changeBackgroundColor();
  }

  void _setInitialScore() {
    playerScoreList = [0, 0, 0, 0];
  }

  startAnimation() {
    colorAnimation = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation = Tween<double>(
      begin: 0,
      end: 30 * math.pi,
    ).animate(colorAnimation)
      ..addListener(() {});
  }

  changeBackgroundColor() {
    colorAnimation.forward();
  }

  setPlayerBgColor() {
    for (var i = 0; i <= widget.players.length - 1; i++) {
      bgColor.add(playerBgColor[i]);
    }
  }

  resetGame() {
    setState(() {
      twoTaps.clear();
      twoTapsElement.clear();
      for (var i = 0; i < totalItems.length; i++) {
        flipController[i].isFront = true;
      }
      playerIndex = 0;
      _setInitialScore();
      images = listOfItems..shuffle();
      totalItems.clear();
      gameStarted = false;
    });
  }

  @override
  void dispose() {
    flipController.map((e) {
      e.dispose();
    }).toList();
    colorAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _printLogs();
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
          height: double.infinity,
          color: bgColor[playerIndex],
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 10.h,
          ),
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Stack(
              children: [
                Center(
                  child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) {
                        return Transform.scale(
                          scale: animation.value,
                          child: Container(
                            height: 20.h,
                            width: 20.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: bgColor[playerIndex],
                            ),
                            alignment: Alignment.center,
                          ),
                        );
                      }),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35.w),
                    child: GridView.builder(
                      itemCount: images.length,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 10,
                        // crossAxisSpacing: 5,
                        childAspectRatio: 1.5,
                      ),
                      itemBuilder: (context, index) {
                        if (flipController.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: () {
                            _onItemPressed(index);
                          },
                          child: FlipAnimation(
                            controller: flipController[index],
                            firstChild: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.r),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40.r),
                                child: Image.asset('assets/images/card_bg.jpg'),
                              ),
                            ),
                            secondChild: Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.r),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40.r),
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                            images[index],
                                          ),
                                          fit: BoxFit.cover)),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (totalItems.length == listOfItems.length)
                  Center(
                    child: GameEndWidget(
                      onPlayTap: () => resetGame(),
                      onMenuTap: null,
                    ),
                  ),
                if (totalItems.length == listOfItems.length)
                  Builder(builder: (context) {
                    var (align, transform) = _getWinnerAlignments();
                    return Align(
                      alignment: align,
                      child: Transform.rotate(
                        alignment: transform,
                        angle: -math.pi / 4,
                        child: Image.asset(
                          'assets/gifs/winner.gif',
                          height: 50.h,
                        ),
                      ),
                    );
                  }),
                for (int i = 0; i < widget.players.length; i++)
                  Align(
                    alignment: [
                      Alignment.topLeft,
                      Alignment.bottomRight,
                      Alignment.topRight,
                      Alignment.bottomLeft,
                    ][i],
                    child: PlayerWidget(
                      color: bgColor[i],
                      score: playerScoreList[i],
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onLongPress: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      widget.bgm.play(AssetSource(narutoBgm));
                    },
                    child: Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 25.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    final value = await showDialog(
        context: context,
        builder: (context) {
          return const CustomDialog();
        });
    if (value == true) {
      if (!mounted) return false;
      Navigator.pop(context);
    }
    return false;
  }

  void _onItemPressed(int index) async {
    if (twoTaps.length < 2 && !totalItems.contains(index)) {
      flipController[index].flip();
      log(flipController[index].value.toString(), name: 'flipedd');
      twoTaps.add(index);
      totalItems.add(index);
      twoTapsElement.add(listOfItems[index]);
      if (twoTaps.length == 2) {
        if (twoTapsElement[0] == twoTapsElement[1]) {
          playerScoreList[playerIndex]++;
          if (listOfItems.length != totalItems.length) {
            twoTaps.clear();
            twoTapsElement.clear();
          } else {}
        } else {
          await Future.delayed(const Duration(milliseconds: 800)).then(
            (value) {
              flipController[twoTaps[0]].flip();
              flipController[twoTaps[1]].flip();
              totalItems.remove(twoTaps[0]);
              totalItems.remove(twoTaps[1]);
              if (playerIndex < widget.players.length - 1) {
                setState(() {
                  playerIndex++;
                  colorAnimation.value = 0;
                  gameStarted = true;
                });
                // changeBackgroundColor();
              } else {
                setState(() {
                  playerIndex = 0;
                  colorAnimation.value = 0;
                });
                // changeBackgroundColor();
              }
              twoTaps.clear();
              twoTapsElement.clear();
            },
          );
        }
      }
    } else {
      if (totalItems.length == listOfItems.length) {}
    }
  }

  (Alignment align, Alignment transform) _getWinnerAlignments() {
    var align = Alignment.center;
    var transform = Alignment.center;
    if (playerScoreList[0] > playerScoreList[1] &&
        playerScoreList[0] > playerScoreList[2] &&
        playerScoreList[0] > playerScoreList[3]) {
      align = Alignment.topLeft;
      transform = Alignment.bottomRight;
    } else if (playerScoreList[1] > playerScoreList[2] &&
        playerScoreList[1] > playerScoreList[3]) {
      align = Alignment.topLeft;
      align = Alignment.bottomRight;
    } else if (playerScoreList[2] > playerScoreList[3]) {
      align = Alignment.bottomRight;
      transform = Alignment.topLeft;
    } else {
      align = Alignment.bottomLeft;
      transform = Alignment.topRight;
    }
    return (align, transform);
  }

  void _printLogs() {
    log(playerScoreList[0].toString(), name: 'score1');
    log(playerScoreList[1].toString(), name: 'score2');
    log(playerScoreList[2].toString(), name: 'score3');
    log(playerScoreList[3].toString(), name: 'score4');
    log('build rebuild');
    log(widget.players[playerIndex]);
    log(widget.players.length.toString(), name: 'number of players');
    log(bgColor.toString(), name: 'bg color');
  }
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Give Up"),
      content: const Text(
          "Is it okay for you if your friends mocks you by saying that you are a guy who easily give up??"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text("Yes"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("No! I Never Give up."),
        ),
      ],
    );
  }
}
