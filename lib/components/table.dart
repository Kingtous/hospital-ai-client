// Copyright 2023 a1147
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

class Frame extends StatefulWidget {
  final Widget title;
  const Frame({super.key, required this.title});

  @override
  State<Frame> createState() => _FrameState();
}

class _FrameState extends State<Frame> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(width: 2.0, color: Colors.white),
          gradient: LinearGradient(colors: [
            Color(0xFFFFFFC2).withAlpha((255 * 0.76).toInt()),
            Color(0xFFDEFFC2).withAlpha((255 * 0.76).toInt()),
          ])),
      child: Column(
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'asset/images/frame_tile_prefix_icon.png',
                width: 20,
                height: 20,
              ),
              SizedBox(
                width: 8.0,
              ),
              widget.title,
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
