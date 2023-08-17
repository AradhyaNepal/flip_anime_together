import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flip_anime_together/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/constants.dart';
import '../../widgets/flip_animation.dart';
import '../../widgets/game_end_widget.dart';
import '../../widgets/player_widget.dart';
import 'board_event.dart';
//Song: My Mind goes salalalala

class GameBoard extends StatefulWidget {
  final StreamController<BoardEvent> boardController;
  final List<Players> players;

  const GameBoard({
    super.key,
    required this.players,
    required this.boardController,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  final List<FlipController> _flipController =
      List.generate(boardItems.length, (i) => FlipController());

  ///On user's turn they have tap two elements to check whether they match.
  ///This list stores the index of the two elements pressed
  final List<int> _twoTapsIndex = [];

  final List<int> _alreadyFlippedItemsIndex = [];
  final List<String> _allBoardItems = List.from(boardItems)..shuffle();

  int _currentTurnIndex = 0;
  final List<int> _playerScoreList = [];
  final List<Color> _backgroundColor = List.from(playerBgColor);
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 30 * math.pi,
    ).animate(_animationController);
    _setInitialScore();
  }

  @override
  void dispose() {
    _flipController.map((e) {
      e.dispose();
    }).toList();
    _animationController.dispose();
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
          color: _backgroundColor[_currentTurnIndex],
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
                              color: _backgroundColor[_currentTurnIndex],
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
                      itemCount: _allBoardItems.length,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 10,
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
                                        _allBoardItems[index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_alreadyFlippedItemsIndex.length ==
                    _allBoardItems.length) ...[
                  Center(
                    child: GameEndWidget(
                      onPlayTap: () => _resetGame(),
                      onMenuTap: null,
                    ),
                  ),
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
                ],
                for (int i = 0; i < widget.players.length; i++)
                  Align(
                    alignment: [
                      Alignment.topLeft,
                      Alignment.bottomRight,
                      Alignment.topRight,
                      Alignment.bottomLeft,
                    ][i],
                    child: PlayerWidget(
                      color: _backgroundColor[i],
                      score: _playerScoreList[i],
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onLongPress: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
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
    _playerScoreList.clear();
    _playerScoreList.addAll([0, 0, 0, 0]);
  }

  void _resetGame() {
    setState(() {
      _twoTapsIndex.clear();
      _flipController.map((e) => e.isFront = true).toList();
      _currentTurnIndex = 0;
      _setInitialScore();
      _allBoardItems.shuffle();
      _alreadyFlippedItemsIndex.clear();
    });
    widget.boardController.add(NewGame());
  }

  Future<bool> _onBackPressed() async {
    final value = await showDialog(
        context: context,
        builder: (context) {
          return const CustomDialog(
            heading: "Give Up",
            title:
                "Is it okay for you if your friends mocks you by saying that you are a guy who easily give up??",
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
    if (_twoTapsIndex.length < 2 &&
        !_alreadyFlippedItemsIndex.contains(index)) {
      _flipController[index].flip();
      log(_flipController[index].value.toString(), name: 'flipped');
      _twoTapsIndex.add(index);
      _alreadyFlippedItemsIndex.add(index);
      if (_twoTapsIndex.length == 2) {
        if (_twoTapsIndex[0] == _twoTapsIndex[1]) {
          _playerScoreList[_currentTurnIndex]++;
          if (_allBoardItems.length != _alreadyFlippedItemsIndex.length) {
            _twoTapsIndex.clear();
          }
        } else {
          await Future.delayed(const Duration(milliseconds: 800)).then(
            (value) {
              _flipController[_twoTapsIndex[0]].flip();
              _flipController[_twoTapsIndex[1]].flip();
              _alreadyFlippedItemsIndex.remove(_twoTapsIndex[0]);
              _alreadyFlippedItemsIndex.remove(_twoTapsIndex[1]);
              if (_currentTurnIndex < widget.players.length - 1) {
                setState(() {
                  _currentTurnIndex++;
                  _animationController.value = 0;
                });
                // changeBackgroundColor();
              } else {
                setState(() {
                  _currentTurnIndex = 0;
                  _animationController.value = 0;
                });
                // changeBackgroundColor();
              }
              _twoTapsIndex.clear();
            },
          );
        }
      }
    } else {
      if (_alreadyFlippedItemsIndex.length == _allBoardItems.length) {}
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
    log('Build Rebuild. Below are Players scores.');
    log(_playerScoreList[0].toString(), name: 'score1');
    log(_playerScoreList[1].toString(), name: 'score2');
    log(_playerScoreList[2].toString(), name: 'score3');
    log(_playerScoreList[3].toString(), name: 'score4');
    log(widget.players[_currentTurnIndex].name);
    log(widget.players.length.toString(), name: 'number of players');
    log(_backgroundColor.toString(), name: 'bg color');
  }
}
