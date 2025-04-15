import 'dart:developer';

import 'package:auto_route/annotations.dart' show RoutePage;
import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/app/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rich_field_controller/rich_field_controller.dart';

@RoutePage()
class Note07PageOne extends StatefulWidget {
  const Note07PageOne({super.key});

  @override
  State<Note07PageOne> createState() => _Note07PageOneState();
}

class _Note07PageOneState extends State<Note07PageOne> {
  final notes = <String>[];
  late final RichFieldController _controller;
  late final FocusNode _fieldFocusNode;

  @override
  void initState() {
    super.initState();
    _fieldFocusNode = FocusNode();
    _controller = RichFieldController(focusNode: _fieldFocusNode);
  }

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note (rich_field_controller) [still in progress]'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton.outlined(
              onPressed: () {
                final a = _controller.toMarkdown();
                setState(() {
                  notes.add(a);
                });
              },
              icon: const Icon(
                Icons.save_alt_outlined,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    leading: Text("${index + 1}."),
                    subtitle: Text(note),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.teal.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RichfieldToolBarExample(_controller),
                  // Divider(),
                  TextField(
                    controller: _controller,
                    focusNode: _fieldFocusNode,
                    maxLines: null,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Write something here...',
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12)),
                      ),
                      filled: true,
                      // border: InputBorder.none,
                      //focusedBorder: InputBorder.none,
                      //enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => context.router.push(const Note07RouteThree()),
      //   label: const Text('Create Note'),
      //   icon: const Icon(Icons.book),
      // ),
    );
  }
}

@RoutePage()
class Note07PageTwo extends HookWidget {
  const Note07PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

@RoutePage()
class Note07PageThree extends StatelessWidget {
  const Note07PageThree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: null,
    );
  }
}

enum FontObject { none, bold, italics, underline, strikeThrough }

class RichfieldToolBarExample extends HookWidget {
  const RichfieldToolBarExample(
    this.controller, {
    super.key,
  });
  final RichFieldController controller;

  @override
  Widget build(BuildContext context) {
    final tappedObject = useState(FontObject.none);

    void onTappedObj(FontObject obj) {
      if (tappedObject.value == obj) {
        tappedObject.value = FontObject.none;
      } else {
        tappedObject.value = obj;
      }
    }

    Color fontObjColor(FontObject obj) {
      return tappedObject.value == obj
          ? Colors.white
          : Theme.of(context).hintColor;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 14),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FontButton(
                onTap: () {
                  controller.updateStyle(
                    const TextStyle(fontWeight: FontWeight.bold),
                  );
                  onTappedObj(FontObject.bold);
                },
                child: Icon(
                  Icons.format_bold_outlined,
                  color: fontObjColor(FontObject.bold),
                ),
              ),

              FontButton(
                onTap: () {
                  controller.updateStyle(
                      const TextStyle(fontStyle: FontStyle.italic));
                  onTappedObj(FontObject.italics);
                },
                child: Icon(
                  Icons.format_italic_outlined,
                  color: fontObjColor(FontObject.italics),
                ),
              ),

              FontButton(
                onTap: () {
                  controller.updateStyle(
                      const TextStyle(decoration: TextDecoration.underline));
                  onTappedObj(FontObject.underline);
                },
                child: Icon(
                  Icons.format_underlined_outlined,
                  color: fontObjColor(FontObject.underline),
                ),
              ),
              FontButton(
                onTap: () {
                  controller.updateStyle(
                      const TextStyle(decoration: TextDecoration.lineThrough));
                  onTappedObj(FontObject.strikeThrough);
                },
                child: Icon(
                  Icons.format_strikethrough_outlined,
                  color: fontObjColor(FontObject.strikeThrough),
                ),
              ),

              //
              // Highlight text
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      controller.updateStyle(
                        TextStyle(
                          background: Paint()..color = Colors.yellow,
                        ),
                      );
                    },
                    child: Icon(
                      Icons.format_color_fill_rounded,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),

              // MouseRegion(
              //   cursor: SystemMouseCursors.click,
              //   child: Padding(
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              //     child: GestureDetector(
              //       onTap: () {
              //         controller.mainStyle = TextStyle(
              //           fontSize: 24,
              //           fontWeight: FontWeight.bold,
              //           color: Theme.of(context).hintColor,
              //           inherit: true,
              //         );
              //       },
              //       child: const Text(
              //         'H1',
              //         style: TextStyle(
              //           // color: Colors.black54,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class FontButton extends StatelessWidget {
  const FontButton({super.key, this.onTap, this.child});
  final void Function()? onTap;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: GestureDetector(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

//MER-vZpX-KAR7-Y7TwQ
