import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../domain/models/drawing_tool.dart';
import '../../domain/models/models.dart';
import '../../src.dart';
import '../notifiers/current_stroke_value_notifier.dart';
import 'color_palette.dart';

class CanvasSideBar extends StatefulWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingTool> drawingTool;
  final CurrentStrokeValueNotifier currentSketch;
  final ValueNotifier<List<Stroke>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<bool> filled;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<ui.Image?> backgroundImage;
  final UndoRedoStack undoRedoStack;
  final ValueNotifier<bool> showGrid;

  const CanvasSideBar({
    Key? key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingTool,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
    required this.backgroundImage,
    required this.undoRedoStack,
    required this.showGrid,
  }) : super(key: key);

  @override
  State<CanvasSideBar> createState() => _CanvasSideBarState();
}

class _CanvasSideBarState extends State<CanvasSideBar> {
  UndoRedoStack get undoRedoStack => widget.undoRedoStack;

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: MediaQuery.of(context).size.height < 680 ? 450 : 610,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.selectedColor,
          widget.strokeSize,
          widget.eraserSize,
          widget.drawingTool,
          widget.filled,
          widget.polygonSides,
          widget.backgroundImage,
          widget.showGrid,
        ]),
        builder: (context, _) {
          return Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              controller: scrollController,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Hình dạng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    _IconBox(
                      iconData: FontAwesomeIcons.pencil,
                      selected: widget.drawingTool.value == DrawingTool.pencil,
                      onTap: () =>
                          widget.drawingTool.value = DrawingTool.pencil,
                      tooltip: 'Bút chì',
                    ),
                    _IconBox(
                      selected: widget.drawingTool.value == DrawingTool.line,
                      onTap: () => widget.drawingTool.value = DrawingTool.line,
                      tooltip: 'Đường kẻ',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 22,
                            height: 2,
                            color: widget.drawingTool.value == DrawingTool.line
                                ? Colors.grey[900]
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    _IconBox(
                      iconData: Icons.hexagon_outlined,
                      selected: widget.drawingTool.value == DrawingTool.polygon,
                      onTap: () =>
                          widget.drawingTool.value = DrawingTool.polygon,
                      tooltip: 'Đa giác',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.eraser,
                      selected: widget.drawingTool.value == DrawingTool.eraser,
                      onTap: () =>
                          widget.drawingTool.value = DrawingTool.eraser,
                      tooltip: 'Cục tẩy',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.square,
                      selected: widget.drawingTool.value == DrawingTool.square,
                      onTap: () =>
                          widget.drawingTool.value = DrawingTool.square,
                      tooltip: 'Square',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.circle,
                      selected: widget.drawingTool.value == DrawingTool.circle,
                      onTap: () =>
                          widget.drawingTool.value = DrawingTool.circle,
                      tooltip: 'Hình tròn',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.ruler,
                      selected: widget.showGrid.value,
                      onTap: () =>
                          widget.showGrid.value = !widget.showGrid.value,
                      tooltip: 'Guide Lines',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Điền vào hình dạng: ',
                      style: TextStyle(fontSize: 12),
                    ),
                    Checkbox(
                      value: widget.filled.value,
                      onChanged: (val) {
                        widget.filled.value = val ?? false;
                      },
                    ),
                  ],
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: widget.drawingTool.value == DrawingTool.polygon
                      ? Row(
                          children: [
                            const Text(
                              'Các cạnh của đa giác: ',
                              style: TextStyle(fontSize: 12),
                            ),
                            Slider(
                              value: widget.polygonSides.value.toDouble(),
                              min: 3,
                              max: 8,
                              onChanged: (val) {
                                widget.polygonSides.value = val.toInt();
                              },
                              label: '${widget.polygonSides.value}',
                              divisions: 5,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Màu sắc',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ColorPalette(
                  selectedColorListenable: widget.selectedColor,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Kích thước ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Row(
                  children: [
                    const Text(
                      'Kích thước nét chữ:  ',
                      style: TextStyle(fontSize: 12),
                    ),
                    Slider(
                      value: widget.strokeSize.value,
                      min: 0,
                      max: 50,
                      onChanged: (val) {
                        widget.strokeSize.value = val;
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Kích thước tẩy:  ',
                      style: TextStyle(fontSize: 12),
                    ),
                    Slider(
                      value: widget.eraserSize.value,
                      min: 0,
                      max: 80,
                      onChanged: (val) {
                        widget.eraserSize.value = val;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hành động',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Wrap(
                  children: [
                    TextButton(
                      onPressed: widget.allSketches.value.isNotEmpty
                          ? () => undoRedoStack.undo()
                          : null,
                      child: const Text('Hoàn tác'),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: undoRedoStack.canRedo,
                      builder: (_, canRedo, __) {
                        return TextButton(
                          onPressed:
                              canRedo ? () => undoRedoStack.redo() : null,
                          child: const Text('Làm lại'),
                        );
                      },
                    ),
                    TextButton(
                      child: const Text('Xoá toàn bộ'),
                      onPressed: () => undoRedoStack.clear(),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (widget.backgroundImage.value != null) {
                          widget.backgroundImage.value = null;
                        } else {
                          widget.backgroundImage.value = await _getImage;
                        }
                      },
                      child: Text(
                        widget.backgroundImage.value == null
                            ? 'Thêm hình nền'
                            : 'Xoá hình nền',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tải về',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: TextButton(
                        child: const Text('Tải về file PNG'),
                        onPressed: () async {
                          Uint8List? pngBytes = await getBytes();
                          if (pngBytes != null) saveFile(pngBytes, 'png');
                        },
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: TextButton(
                        child: const Text('Tải về file JPEG'),
                        onPressed: () async {
                          Uint8List? pngBytes = await getBytes();
                          if (pngBytes != null) saveFile(pngBytes, 'jpeg');
                        },
                      ),
                    ),
                  ],
                ),
                // add about me button or follow buttons
                const Divider(),
                // Center(
                //   child: GestureDetector(
                //     onTap: () => _launchUrl('https://github.com/JideGuru'),
                //     child: const Text(
                //       'Made with 💙 by JideGuru',
                //       style: TextStyle(fontSize: 12),
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  void saveFile(Uint8List bytes, String extension) async {
    if (kIsWeb) {
      html.AnchorElement()
        ..href = '${Uri.dataFromBytes(bytes, mimeType: 'image/$extension')}'
        ..download =
            'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension'
        ..style.display = 'none'
        ..click();
    } else {
      await FileSaver.instance.saveFile(
        name: 'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension',
        bytes: bytes,
        ext: extension,
        mimeType: extension == 'png' ? MimeType.png : MimeType.jpeg,
      );
    }
  }

  Future<ui.Image> get _getImage async {
    final completer = Completer<ui.Image>();
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (file != null) {
        final filePath = file.files.single.path;
        final bytes = filePath == null
            ? file.files.first.bytes
            : File(filePath).readAsBytesSync();
        if (bytes != null) {
          completer.complete(decodeImageFromList(bytes));
        } else {
          completer.completeError('No image selected');
        }
      }
    } else {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        completer.complete(
          decodeImageFromList(bytes),
        );
      } else {
        completer.completeError('No image selected');
      }
    }

    return completer.future;
  }

  Future<void> _launchUrl(String url) async {
    if (kIsWeb) {
      html.window.open(
        url,
        url,
      );
    } else {
      if (!await launchUrl(Uri.parse(url))) {
        throw 'Could not launch $url';
      }
    }
  }

  Future<Uint8List?> getBytes() async {
    RenderRepaintBoundary boundary = widget.canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBox({
    Key? key,
    this.iconData,
    this.child,
    this.tooltip,
    required this.selected,
    required this.onTap,
  })  : assert(child != null || iconData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.grey[900]! : Colors.grey,
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Tooltip(
            message: tooltip,
            preferBelow: false,
            child: child ??
                Icon(
                  iconData,
                  color: selected ? Colors.grey[900] : Colors.grey,
                  size: 20,
                ),
          ),
        ),
      ),
    );
  }
}
