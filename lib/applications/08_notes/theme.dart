import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart'
    show FollowerAlignment;

FollowerAlignment popoverAligner(Rect globalLeaderRect, Size followerSize,
    Size screenSize, GlobalKey? boundaryKey) {
  return const FollowerAlignment(
    leaderAnchor: Alignment.bottomLeft,
    followerAnchor: Alignment.topLeft,
    followerOffset: Offset(0, 1),
  );
}
