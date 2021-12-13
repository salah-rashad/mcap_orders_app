import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/rx_file_model.dart';
import 'package:mcap_orders_app/app/modules/add_report/add_report_controller.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/utils/extensions.dart';
import 'package:open_file/open_file.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FileItem extends StatelessWidget {
  final AddReportController? controller;
  final RxFile? rxFile;
  final VoidCallback? onDelete;
  final String? url;

  final bool _isDownload;

  const FileItem({
    Key? key,
    required this.controller,
    required this.rxFile,
    this.onDelete,
  })  : _isDownload = false,
        url = null,
        super(key: key);

  const FileItem.download({
    Key? key,
    required this.url,
  })  : _isDownload = true,
        controller = null,
        rxFile = null,
        onDelete = null,
        super(key: key);

  bool get isImage => rxFile!.file.path.isImageFileName;

  @override
  Widget build(BuildContext context) {
    return _isDownload
        ? GestureDetector(
            onTap: () => OpenFile.open(url),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: FittedBox(
                fit: BoxFit.cover,
                child: CachedNetworkImage(
                  imageUrl: url ?? "",
                  imageBuilder: (context, imageProvider) {
                    return GestureDetector(
                      onTap: () async {
                        final path = await _findPath(url!);
                        OpenFile.open(path);
                      },
                      child: Image(image: imageProvider),
                    );
                  },
                ),
              ),
            ),
          )
        : Stack(
            clipBehavior: Clip.antiAlias,
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () => OpenFile.open(rxFile!.file.path),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: isImage
                      ? Image.file(
                          rxFile!.file.toFile!,
                          fit: BoxFit.cover,
                        )
                      : FutureBuilder<String?>(
                          future: VideoThumbnail.thumbnailFile(
                            video: rxFile!.file.path,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasError) {
                                return const Text('Error');
                              } else if (snapshot.hasData) {
                                final data = snapshot.data ?? "";
                                return Image.file(
                                  File.fromUri(Uri.parse(data)),
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return const Text('Empty data');
                              }
                            } else {
                              return Text('State: ${snapshot.connectionState}');
                            }
                          },
                        ),
                ),
              ),
              Obx(() {
                return rxFile!.uploadStatus != UploadStatus.NONE
                    ? Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: onDelete,
                          color: Palette.RED,
                          icon: const Icon(Icons.delete_forever),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                    : const SizedBox.shrink();
              }),
              if (!isImage)
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 32.0,
                    ),
                  ),
                ),
              Obx(
                () {
                  if (rxFile!.uploadStatus == UploadStatus.ACTIVE) {
                    return const Align(
                      alignment: Alignment.bottomCenter,
                      child: Center(
                        child: Chip(
                          label: Icon(
                            Icons.upload_rounded,
                            color: Palette.black,
                          ),
                        ),
                      ),
                    );
                  } else {
                    if (rxFile!.uploadStatus == UploadStatus.DONE) {
                      return const Center(
                        child: Chip(
                          label: Icon(
                            Icons.check_circle_rounded,
                            color: Palette.GREEN,
                          ),
                        ),
                      );
                    } else {
                      if (rxFile!.uploadStatus == UploadStatus.ERROR) {
                        return const Center(
                          child: Chip(
                            label: Icon(
                              Icons.error_rounded,
                              color: Palette.RED,
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                  }
                },
              )
            ],
          );
  }

  Future<String?> _findPath(String imageUrl) async {
    final cache = DefaultCacheManager();
    final file = await cache.getFileFromCache(imageUrl);
    return file?.file.path;
  }
}
