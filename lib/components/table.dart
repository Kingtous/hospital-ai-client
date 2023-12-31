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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:hospital_ai_client/constants.dart';

class Frame extends StatefulWidget {
  final Widget title;
  final Widget content;
  const Frame({super.key, required this.title, required this.content});

  @override
  State<Frame> createState() => _FrameState();
}

class _FrameState extends State<Frame> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(width: 2.0, color: Colors.white),
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color(0xFFDEEFFF).withAlpha((255 * 0.76).toInt()),
                const Color(0xFFFFFFFF).withAlpha((255 * 0.76).toInt()),
              ])),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/frame_tile_prefix_icon.png',
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 8.0,
              ),
              widget.title,
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Offstage(
                      offstage: ModalRoute.of(context)?.settings.name == '' ||
                          ModalRoute.of(context)?.settings.name == 'home',
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            // logger.d(
                            // 'pop: current is ${ModalRoute.of(context)?.settings.name}');
                          },
                          child: const MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Icon(Icons.close))),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 2,
                  child: Image.asset(
                    'assets/images/frame_line.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          Expanded(child: widget.content)
        ],
      ),
    );
  }
}
