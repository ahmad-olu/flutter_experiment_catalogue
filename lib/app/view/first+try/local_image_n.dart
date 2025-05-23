import 'dart:io' show File;

import 'package:attributed_text/attributed_text.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/src/default_editor/layout_single_column/selection_aware_viewmodel.dart';
import 'package:super_editor/src/default_editor/selection_upstream_downstream.dart';
import 'package:super_editor/super_editor.dart';

/// [DocumentNode] that represents an image at a URL.
@immutable
class LocalImageNode extends BlockNode {
  LocalImageNode({
    required this.id,
    required this.imageUrl,
    this.expectedBitmapSize,
    this.altText = '',
    super.metadata,
  }) {
    initAddToMetadata({'blockType': const NamedAttribution('local-image')});
  }

  @override
  final String id;

  final String imageUrl;

  /// The expected size of the image.
  ///
  /// Used to size the component while the image is still being loaded,
  /// so the content don't shift after the image is loaded.
  ///
  /// It's technically permissible to provide only a single expected dimension,
  /// however providing only a single dimension won't provide enough information
  /// to size an image component before the image is loaded. Providing only a
  /// width in a vertical layout won't have any visual effect. Providing only a height
  /// in a vertical layout will likely take up more space or less space than the final
  /// image because the final image will probably be scaled. Therefore, to take
  /// advantage of [ExpectedSize], you should try to provide both dimensions.
  final ExpectedSize? expectedBitmapSize;

  final String altText;

  @override
  String? copyContent(dynamic selection) {
    if (selection is! UpstreamDownstreamNodeSelection) {
      throw Exception(
          'LocalImageNode can only copy content from a UpstreamDownstreamNodeSelection.');
    }

    return !selection.isCollapsed ? imageUrl : null;
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is LocalImageNode &&
        imageUrl == other.imageUrl &&
        altText == other.altText;
  }

  @override
  DocumentNode copyWithAddedMetadata(Map<String, dynamic> newProperties) {
    return LocalImageNode(
      id: id,
      imageUrl: imageUrl,
      expectedBitmapSize: expectedBitmapSize,
      altText: altText,
      metadata: {
        ...metadata,
        ...newProperties,
      },
    );
  }

  @override
  DocumentNode copyAndReplaceMetadata(Map<String, dynamic> newMetadata) {
    return LocalImageNode(
      id: id,
      imageUrl: imageUrl,
      expectedBitmapSize: expectedBitmapSize,
      altText: altText,
      metadata: newMetadata,
    );
  }

  @override
  LocalImageNode copy() {
    return LocalImageNode(
      id: id,
      imageUrl: imageUrl,
      expectedBitmapSize: expectedBitmapSize,
      altText: altText,
      metadata: Map.from(metadata),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalImageNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          imageUrl == other.imageUrl &&
          altText == other.altText;

  @override
  int get hashCode => id.hashCode ^ imageUrl.hashCode ^ altText.hashCode;
}

class LocalImageComponentBuilder implements ComponentBuilder {
  const LocalImageComponentBuilder();

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
      Document document, DocumentNode node) {
    if (node is! LocalImageNode) {
      return null;
    }

    return LocalImageComponentViewModel(
      nodeId: node.id,
      imageUrl: node.imageUrl,
      expectedSize: node.expectedBitmapSize,
    );
  }

  @override
  Widget? createComponent(SingleColumnDocumentComponentContext componentContext,
      SingleColumnLayoutComponentViewModel componentViewModel) {
    if (componentViewModel is! LocalImageComponentViewModel) {
      return null;
    }

    return LocalImageComponent(
      componentKey: componentContext.componentKey,
      imageUrl: componentViewModel.imageUrl,
      expectedSize: componentViewModel.expectedSize,
      selection: componentViewModel.selection?.nodeSelection
          as UpstreamDownstreamNodeSelection?,
      selectionColor: componentViewModel.selectionColor,
    );
  }
}

class LocalImageComponentViewModel extends SingleColumnLayoutComponentViewModel
    with SelectionAwareViewModelMixin {
  LocalImageComponentViewModel({
    required super.nodeId,
    super.maxWidth,
    super.padding = EdgeInsets.zero,
    required this.imageUrl,
    this.expectedSize,
    DocumentNodeSelection? selection,
    Color selectionColor = Colors.transparent,
  }) {
    this.selection = selection;
    this.selectionColor = selectionColor;
  }

  String imageUrl;
  ExpectedSize? expectedSize;

  @override
  LocalImageComponentViewModel copy() {
    return LocalImageComponentViewModel(
      nodeId: nodeId,
      maxWidth: maxWidth,
      padding: padding,
      imageUrl: imageUrl,
      expectedSize: expectedSize,
      selection: selection,
      selectionColor: selectionColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is LocalImageComponentViewModel &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          imageUrl == other.imageUrl &&
          selection == other.selection &&
          selectionColor == other.selectionColor;

  @override
  int get hashCode =>
      super.hashCode ^
      nodeId.hashCode ^
      imageUrl.hashCode ^
      selection.hashCode ^
      selectionColor.hashCode;
}

/// Displays an image in a document.
class LocalImageComponent extends StatelessWidget {
  const LocalImageComponent({
    Key? key,
    required this.componentKey,
    required this.imageUrl,
    this.expectedSize,
    this.selectionColor = Colors.blue,
    this.selection,
    this.imageBuilder,
  }) : super(key: key);

  final GlobalKey componentKey;
  final String imageUrl;
  final ExpectedSize? expectedSize;
  final Color selectionColor;
  final UpstreamDownstreamNodeSelection? selection;

  /// Called to obtain the inner image for the given [imageUrl].
  ///
  /// This builder is used in tests to 'mock' an [Image], avoiding accessing the network.
  ///
  /// If [imageBuilder] is `null` an [Image] is used.
  final Widget Function(BuildContext context, String imageUrl)? imageBuilder;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      hitTestBehavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        child: Center(
          child: SelectableBox(
            selection: selection,
            selectionColor: selectionColor,
            child: BoxComponent(
              key: componentKey,
              child: imageBuilder != null
                  ? imageBuilder!(context, imageUrl)
                  : Image.file(
                      File(imageUrl),
                      fit: BoxFit.contain,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (frame != null) {
                          // The image is already loaded. Use the image as is.
                          return child;
                        }

                        if (expectedSize != null &&
                            expectedSize!.width != null &&
                            expectedSize!.height != null) {
                          // Both width and height were provide.
                          // Preserve the aspect ratio of the original image.
                          return AspectRatio(
                            aspectRatio: expectedSize!.aspectRatio,
                            child: SizedBox(
                              width: expectedSize!.width!.toDouble(),
                              height: expectedSize!.height!.toDouble(),
                            ),
                          );
                        }

                        // The image is still loading and only one dimension was provided.
                        // Use the given dimension.
                        return SizedBox(
                          width: expectedSize?.width?.toDouble(),
                          height: expectedSize?.height?.toDouble(),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The expected size of a piece of content, such as an image that's loading.
class ExpectedSize {
  const ExpectedSize(this.width, this.height);

  final int? width;
  final int? height;

  double get aspectRatio => height != null //
      ? (width ?? 0) / height!
      : throw UnsupportedError(
          "Can't compute the aspect ratio with a null height");

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpectedSize && //
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}
