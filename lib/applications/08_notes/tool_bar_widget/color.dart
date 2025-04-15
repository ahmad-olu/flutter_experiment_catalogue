import 'package:experiment_catalogue/app/view/example/example_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:overlord/overlord.dart';
import 'package:super_editor/super_editor.dart';

const tooltipDelay = Duration(milliseconds: 500);

// BuildColorButton(
//           composer: composer,
//           document: document,
//           editor: editor,
//           attributions: attributions,
//           editorFocusNode: editorFocusNode,
//           tapRegionGroupId: _tapRegionGroupId,
//           defaultEdit: defaultEdit,
//         ),
//         BuildBackgroundColorButton(
//           composer: composer,
//           document: document,
//           editor: editor,
//           attributions: attributions,
//           editorFocusNode: editorFocusNode,
//           tapRegionGroupId: _tapRegionGroupId,
//           defaultEdit: defaultEdit,
//         ),

class BuildBackgroundColorButton extends HookWidget {
  const BuildBackgroundColorButton({
    required this.composer,
    required this.document,
    required this.editor,
    required this.attributions,
    required this.editorFocusNode,
    required this.tapRegionGroupId,
    required this.defaultEdit,
    super.key,
  });

  final Set<Attribution> attributions;
  final FocusNode editorFocusNode;
  final String tapRegionGroupId;

  final MutableDocumentComposer composer;
  final MutableDocument document;
  final Editor editor;
  final ValueNotifier<GlobalStyleEdit> defaultEdit;
  //final Widget Function(BuildContext, Color?) colorButtonBuilder;

  @override
  Widget build(BuildContext context) {
    // final colorAttribution =
    //     attributions.whereType<ColorAttribution>().firstOrNull;

    return Tooltip(
      message: 'Highlight color',
      waitDuration: tooltipDelay,
      child: ColorSelector(
        colorButtonBuilder: (context, selectedColor) => Stack(
          children: [
            const Icon(Icons.format_color_fill),
            Positioned(
              bottom: 0,
              left: 1,
              child: Container(
                width: 16,
                height: 4,
                color: selectedColor ?? Colors.black,
              ),
            ),
          ],
        ),
        onSelected: (newColor) {
          final selection = composer.selection;

          if (selection == null) {
            return;
          }
          final colorAttributions =
              document.getAttributionsByType<ColorAttribution>(selection);

          final basePosition = selection.base.nodePosition;
          final extentPosition = selection.extent.nodePosition;
          if (basePosition is TextNodePosition &&
              extentPosition is TextNodePosition) {
            final start = basePosition.offset;
            final end = extentPosition.offset;
            if (start == end || start >= -1 && start > end) {
              //FIXME: : dont know the default highlight color to reset this
              //   composer.preferences.clearStyles();
              //   composer.preferences
              //       .addStyle(BackgroundColorAttribution(newColor!));

              //   defaultEdit.value =
              //       defaultEdit.value.copyWith(defaultHighlightColor: newColor);
            } else {
              editor.execute([
                InsertTextRequest(
                  documentPosition: selection.extent,
                  textToInsert: ' ',
                  attributions: {},
                  //  attributions: {paragraphAttribution},
                ),
                for (final existingAttribution in colorAttributions) //
                  RemoveTextAttributionsRequest(
                      documentRange: selection,
                      attributions: {existingAttribution}),
                if (newColor != null) //
                  AddTextAttributionsRequest(
                    documentRange: selection,
                    attributions: {BackgroundColorAttribution(newColor)},
                  ),
              ]);
            }
          }
        },
        editorFocusNode: editorFocusNode,
        tapRegionGroupId: tapRegionGroupId,
        selectedColor: defaultEdit.value.defaultHighlightColor,
        // selectedColor: color.value ?? Colors.black,
        //  showClearButton: true,
      ),
    );
  }
}

class BuildColorButton extends HookWidget {
  const BuildColorButton({
    required this.composer,
    required this.document,
    required this.editor,
    required this.attributions,
    required this.editorFocusNode,
    required this.tapRegionGroupId,
    required this.defaultEdit,
    super.key,
  });

  final Set<Attribution> attributions;
  final FocusNode editorFocusNode;
  final String tapRegionGroupId;
  final MutableDocumentComposer composer;
  final MutableDocument document;
  final Editor editor;
  final ValueNotifier<GlobalStyleEdit> defaultEdit;
  //final Widget Function(BuildContext, Color?) colorButtonBuilder;

  @override
  Widget build(BuildContext context) {
    // final colorAttribution =
    //     attributions.whereType<ColorAttribution>().firstOrNull;

    return Tooltip(
      message: 'Text color',
      waitDuration: tooltipDelay,
      child: ColorSelector(
        colorButtonBuilder: (context, selectedColor) => Stack(
          children: [
            const Icon(Icons.format_color_text),
            Positioned(
              bottom: 0,
              left: 1,
              child: Container(
                width: 16,
                height: 4,
                color: selectedColor ?? Colors.black,
              ),
            ),
          ],
        ),
        onSelected: (newColor) {
          final selection = composer.selection;

          if (selection == null) {
            return;
          }
          final colorAttributions =
              document.getAttributionsByType<ColorAttribution>(selection);

          final basePosition = selection.base.nodePosition;
          final extentPosition = selection.extent.nodePosition;
          if (basePosition is TextNodePosition &&
              extentPosition is TextNodePosition) {
            final start = basePosition.offset;
            final end = extentPosition.offset;
            if (start == end || start >= -1 && start > end) {
              composer.preferences.clearStyles();
              composer.preferences.addStyle(ColorAttribution(newColor!));

              defaultEdit.value =
                  defaultEdit.value.copyWith(defaultColor: newColor);
            } else {
              editor.execute([
                InsertTextRequest(
                  documentPosition: selection.extent,
                  textToInsert: ' ',
                  attributions: {},
                  //  attributions: {paragraphAttribution},
                ),
                for (final existingAttribution in colorAttributions) //
                  RemoveTextAttributionsRequest(
                      documentRange: selection,
                      attributions: {existingAttribution}),
                if (newColor != null) //
                  AddTextAttributionsRequest(
                    documentRange: selection,
                    attributions: {ColorAttribution(newColor)},
                    autoMerge: false,
                  ),
              ]);
            }
          }
        },
        editorFocusNode: editorFocusNode,
        tapRegionGroupId: tapRegionGroupId,
        selectedColor: defaultEdit.value.defaultColor,
        // selectedColor: color.value ?? Colors.black,
        showClearButton: false,
      ),
    );
  }
}

class ColorSelector extends HookWidget {
  const ColorSelector({
    required this.onSelected,
    required this.editorFocusNode,
    required this.tapRegionGroupId,
    required this.selectedColor,
    required this.colorButtonBuilder,
    super.key,
    this.showClearButton = false,
  });

  final void Function(Color?) onSelected;
  final FocusNode editorFocusNode;
  final String tapRegionGroupId;
  final bool showClearButton;
  final Color? selectedColor;
  final Widget Function(BuildContext, Color?) colorButtonBuilder;

  @override
  Widget build(BuildContext context) {
    final activeIndex = useState<int?>(null);
    const columnCount = 10;
    final popoverController = useMemoized(PopoverController.new, []);
    final popOverFocusNode = useMemoized(FocusNode.new, []);

    useEffect(() {
      return () {
        popoverController.dispose();
        popOverFocusNode.dispose();
      };
    }, []);
    Widget buildClearButton() {
      return SizedBox(
        width: 243,
        height: 32,
        child: TextButton.icon(
          onPressed: popoverController.close,
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.all(5)),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                side: BorderSide(),
              ),
            ),
          ),
          icon: const Icon(
            Icons.format_color_reset,
            color: Colors.pink,
          ),
          label: const SizedBox(
            // width: double.infinity,
            child: Text(
              'None',
              textAlign: TextAlign.left,
            ),
          ),
        ),
      );
    }

    Color _getColorForCheckIcon(Color background) {
      // Adapted from https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color/3943023#3943023.
      final intensity = (0.299 * background.red) +
          (0.587 * background.green) +
          (0.114 * background.blue);
      return intensity > 130 ? Colors.black : Colors.white;
    }

    Widget buildColorGrid() {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: defaultColors.length / columnCount * 20,
          maxWidth: 243,
        ),
        child: Focus(
          focusNode: popOverFocusNode,
          //onKeyEvent: _onKeyEvent,
          child: GridView.builder(
            clipBehavior: Clip.none,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
              mainAxisSpacing: 2,
            ),
            itemCount: defaultColors.length,
            itemBuilder: (context, index) {
              final item = defaultColors[index];
              // log('item: $item ===> selectedColor: $selectedColor');
              return InkWell(
                // onTap: () => log('Tapped $item'),
                onTap: () => onSelected(item),
                customBorder: const CircleBorder(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: item,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (activeIndex.value == index) //
                            const BoxShadow(
                              blurRadius: 3,
                            )
                        ],
                      ),
                    ),
                    if (item == selectedColor) //
                      Icon(
                        Icons.check,
                        size: 15,
                        color: _getColorForCheckIcon(item),
                      )
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    return PopoverScaffold(
      controller: popoverController,
      parentFocusNode: editorFocusNode,
      popoverFocusNode: popOverFocusNode,
      buttonBuilder: (context) {
        return TextButton(
          onPressed: popoverController.open,
          // style: defaultToolbarButtonStyle,
          child: colorButtonBuilder(context, selectedColor),
        );
      },
      popoverBuilder: (context) {
        return Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.hardEdge,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showClearButton) //
                  buildClearButton(),
                if (showClearButton) //
                  const SizedBox(height: 3),
                buildColorGrid(),
                //   _buildCustomColorsButton(),
                //   _buildFooterButtons(),
              ],
            ),
          ),
        );
      },
    );
  }
}

const defaultColors = [
  Colors.black,
  Color(0xFF434343),
  Color(0xFF666666),
  Color(0xFF999999),
  Color(0xFFB7B7B7),
  Color(0xFFCCCCCC),
  Color(0xFFD9D9D9),
  Color(0xFFEFEFEF),
  Color(0xFFF3F3F3),
  Color(0xFFDFE0E3),
  //
  Color(0xFF980201),
  Color(0xFFFF0000),
  Color(0xFFFF9900),
  Color(0xFFFFFF00),
  Color(0xFF01FF00),
  Color(0xFF02FFFF),
  Color(0xFF4A86E8),
  Color(0xFF0602FF),
  Color(0xFF9901FF),
  Color(0xFFFF00FF),
  //
  Color(0xFFE6B8AF),
  Color(0xFFF4CCCC),
  Color(0xFFFCE5CD),
  Color(0xFFFFF2CC),
  Color(0xFFD9EAD3),
  Color(0xFFD0E0E3),
  Color(0xFFC9DAF8),
  Color(0xFFCFE2F3),
  Color(0xFFD9D2E9),
  Color(0xFFEAD1DC),
  //
  Color(0xFFDD7E6A),
  Color(0xFFEA9999),
  Color(0xFFF9CB9C),
  Color(0xFFFFE599),
  Color(0xFFB6D7A8),
  Color(0xFFA2C4C9),
  Color(0xFFA4C2F4),
  Color(0xFF9FC5E8),
  Color(0xFFB4A7D6),
  Color(0xFFD5A6BD),
  //
  Color(0xFFCC4125),
  Color(0xFFE06666),
  Color(0xFFF6B26B),
  Color(0xFFFFD965),
  Color(0xFF93C47E),
  Color(0xFF76A5AF),
  Color(0xFF6D9EEB),
  Color(0xFF6FA8DC),
  Color(0xFF8E7CC3),
  Color(0xFFC27BA0),
  //
  Color(0xFFA61C01),
  Color(0xFFCC0200),
  Color(0xFFE69139),
  Color(0xFFF1C233),
  Color(0xFF6AA84F),
  Color(0xFF45808E),
  Color(0xFF3C78D8),
  Color(0xFF3D85C6),
  Color(0xFF674EA7),
  Color(0xFFA64D78),
  //
  Color(0xFF85200C),
  Color(0xFF990201),
  Color(0xFFB45F07),
  Color(0xFFBF9001),
  Color(0xFF38761D),
  Color(0xFF144F5C),
  Color(0xFF1155CC),
  Color(0xFF0B5394),
  Color(0xFF351D75),
  Color(0xFF741B46),
  //
  Color(0xFF5B0E03),
  Color(0xFF660202),
  Color(0xFF783E03),
  Color(0xFF7F6001),
  Color(0xFF274E13),
  Color(0xFF0C343D),
  Color(0xFF1B4487),
  Color(0xFF093763),
  Color(0xFF20124D),
  Color(0xFF4C1230),
  //
];
