import 'dart:developer';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flip_anime_together/widgets/custom_dialog.dart';
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
  List<FlipController> _flipController = [];
  final List _twoTaps = [];
  final List _twoTapsElement = [];
  final List _totalItems = [];
  List<dynamic> _images = [];
  int _playerIndex = 0;
  List<int> _playerScoreList = [];

  final List<Color> _bgColor = [];
  late AnimationController _colorAnimation;
  late Animation<double> _animation;
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();
    _images = listOfItems..shuffle();
    _setInitialScore();
    _setPlayerBgColor();
    _flipController =
        List.generate(listOfItems.length, (i) => FlipController());
    _colorAnimation = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 30 * math.pi,
    ).animate(_colorAnimation)
      ..addListener(() {});
    // changeBackgroundColor();
  }

  @override
  void dispose() {
    _flipController.map((e) {
      e.dispose();
    }).toList();
    _colorAnimation.dispose();
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
          color: _bgColor[_playerIndex],
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
                      animation: _animation,
                      builder: (context, _) {
                        return Transform.scale(
                          scale: _animation.value,
                          child: Container(
                            height: 20.h,
                            width: 20.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: _bgColor[_playerIndex],
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
                      itemCount: _images.length,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 10,
                        // crossAxisSpacing: 5,
                        childAspectRatio: 1.5,
                      ),
                      itemBuilder: (context, index) {
                        if (_flipController.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: () {
                            _onItemPressed(index);
                          },
                          child: FlipAnimation(
                            controller: _flipController[index],
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
                                            _images[index],
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
                if (_totalItems.length == listOfItems.length)
                  Center(
                    child: GameEndWidget(
                      onPlayTap: () => _resetGame(),
                      onMenuTap: null,
                    ),
                  ),
                if (_totalItems.length == listOfItems.length)
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
                      color: _bgColor[i],
                      score: _playerScoreList[i],
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

  void _setInitialScore() {
    _playerScoreList = [0, 0, 0, 0];
  }

  void _setPlayerBgColor() {
    for (var i = 0; i <= widget.players.length - 1; i++) {
      _bgColor.add(playerBgColor[i]);
    }
  }

  void _resetGame() {
    setState(() {
      _twoTaps.clear();
      _twoTapsElement.clear();
      for (var i = 0; i < _totalItems.length; i++) {
        _flipController[i].isFront = true;
      }
      _playerIndex = 0;
      _setInitialScore();
      _images = listOfItems..shuffle();
      _totalItems.clear();
      gameStarted = false;
    });
  }

  Future<bool> _onBackPressed() async {
    final value = await showDialog(
        context: context,
        builder: (context) {
          return const CustomDialog(
            heading: "Give Up",
            title: "Is it okay for you if your friends mocks you by saying that you are a guy who easily give up??",
            yes: "Yes",
            no: "No! I Never Give up.",
          );
        });
    if (value == true) {
      if (!mounted) return false;
      Navigator.pop(context);
    }
    return false;
  }

  void _onItemPressed(int index) async {
    if (_twoTaps.length < 2 && !_totalItems.contains(index)) {
      _flipController[index].flip();
      log(_flipController[index].value.toString(), name: 'flipedd');
      _twoTaps.add(index);
      _totalItems.add(index);
      _twoTapsElement.add(listOfItems[index]);
      if (_twoTaps.length == 2) {
        if (_twoTapsElement[0] == _twoTapsElement[1]) {
          _playerScoreList[_playerIndex]++;
          if (listOfItems.length != _totalItems.length) {
            _twoTaps.clear();
            _twoTapsElement.clear();
          } else {}
        } else {
          await Future.delayed(const Duration(milliseconds: 800)).then(
            (value) {
              _flipController[_twoTaps[0]].flip();
              _flipController[_twoTaps[1]].flip();
              _totalItems.remove(_twoTaps[0]);
              _totalItems.remove(_twoTaps[1]);
              if (_playerIndex < widget.players.length - 1) {
                setState(() {
                  _playerIndex++;
                  _colorAnimation.value = 0;
                  gameStarted = true;
                });
                // changeBackgroundColor();
              } else {
                setState(() {
                  _playerIndex = 0;
                  _colorAnimation.value = 0;
                });
                // changeBackgroundColor();
              }
              _twoTaps.clear();
              _twoTapsElement.clear();
            },
          );
        }
      }
    } else {
      if (_totalItems.length == listOfItems.length) {}
    }
  }

  (Alignment align, Alignment transform) _getWinnerAlignments() {
    var align = Alignment.center;
    var transform = Alignment.center;
    if (_playerScoreList[0] > _playerScoreList[1] &&
        _playerScoreList[0] > _playerScoreList[2] &&
        _playerScoreList[0] > _playerScoreList[3]) {
      align = Alignment.topLeft;
      transform = Alignment.bottomRight;
    } else if (_playerScoreList[1] > _playerScoreList[2] &&
        _playerScoreList[1] > _playerScoreList[3]) {
      align = Alignment.topLeft;
      align = Alignment.bottomRight;
    } else if (_playerScoreList[2] > _playerScoreList[3]) {
      align = Alignment.bottomRight;
      transform = Alignment.topLeft;
    } else {
      align = Alignment.bottomLeft;
      transform = Alignment.topRight;
    }
    return (align, transform);
  }

  void _printLogs() {
    log(_playerScoreList[0].toString(), name: 'score1');
    log(_playerScoreList[1].toString(), name: 'score2');
    log(_playerScoreList[2].toString(), name: 'score3');
    log(_playerScoreList[3].toString(), name: 'score4');
    log('build rebuild');
    log(widget.players[_playerIndex]);
    log(widget.players.length.toString(), name: 'number of players');
    log(_bgColor.toString(), name: 'bg color');
  }
}
