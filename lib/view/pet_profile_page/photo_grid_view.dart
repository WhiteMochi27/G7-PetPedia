// Contributed by: Tong Qian Ru

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/models/album.dart';
import 'package:petpedia/models/photo.dart';
import 'package:petpedia/database/database_handler.dart';
import 'package:image_picker/image_picker.dart';

class PhotoGridView extends StatefulWidget {
  final Album album;
  final List<Album> albums;

  const PhotoGridView({super.key, required this.album, required this.albums});

  @override
  State<PhotoGridView> createState() => _PhotoGridViewState();
}

class _PhotoGridViewState extends State<PhotoGridView> {
  Future<void> _takePicture(int albumId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      try {
        DatabaseHandler db = DatabaseHandler();
        final imageData = {
          'album_id': albumId,
          'image_url': image.path,
          'date_added': db.formatDateForDb(DateTime.now()),
          'caption': null,
        };

        int imageId = await db.insertImage(imageData);

        setState(() {
          currentAlbum.photos.add(
            Photo(id: imageId, date: DateTime.now(), imagePath: image.path),
          );
        });

        if (currentAlbum.name != "All photos") {
          final allPhotosAlbum = widget.albums.firstWhere(
            (album) => album.name == "All photos",
            orElse: () => Album(id: -1, name: "", photos: []),
          );

          if (allPhotosAlbum.id != -1) {
            final allPhotosImageData = {
              'album_id': allPhotosAlbum.id,
              'image_url': image.path,
              'date_added': db.formatDateForDb(DateTime.now()),
              'caption': null,
            };

            await db.insertImage(allPhotosImageData);
          }
        }
      } catch (e) {
        print('Error saving image: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
      }
    }
    Navigator.pop(context, widget.albums);
  }

  Future<void> _pickFromGallery(int albumId) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      try {
        DatabaseHandler db = DatabaseHandler();
        List<Photo> newPhotos = [];

        for (var image in images) {
          final imageData = {
            'album_id': albumId,
            'image_url': image.path,
            'date_added': db.formatDateForDb(DateTime.now()),
            'caption': null,
          };

          int imageId = await db.insertImage(imageData);
          newPhotos.add(
            Photo(id: imageId, date: DateTime.now(), imagePath: image.path),
          );

          if (currentAlbum.name != "All photos") {
            final allPhotosAlbum = widget.albums.firstWhere(
              (album) => album.name == "All photos",
              orElse: () => Album(id: -1, name: "", photos: []),
            );

            if (allPhotosAlbum.id != -1) {
              final allPhotosImageData = {
                'album_id': allPhotosAlbum.id,
                'image_url': image.path,
                'date_added': db.formatDateForDb(DateTime.now()),
                'caption': null,
              };

              await db.insertImage(allPhotosImageData);

            }
          }
        }

        setState(() {
          currentAlbum.photos.addAll(newPhotos);
        });
      } catch (e) {
        print('Error adding images: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding images: $e')));
      }
    }
    Navigator.pop(context, widget.albums);
  }

  late Album currentAlbum;
  bool isSelectionMode = false;
  late List<bool> selectedPhotos;

  @override
  void initState() {
    super.initState();
    currentAlbum = widget.album;
    selectedPhotos = List.generate(currentAlbum.photos.length, (i) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            const PageTitle(
              icon: 'assets/images/icon_album.png',
              title: 'SnapPaws',
              subtitle: 'Pet Album',
            ),

            Positioned(
              top: 100,
              left: 15,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: IconButton(
                  icon: Image.asset('assets/images/icon_back.png'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Positioned.fill(
              top: 100,
              child: Column(
                children: [
                  _buildTopFunctionButtons(),

                  Expanded(child: _buildPhotoGrid()),
                ],
              ),
            ),

            if (isSelectionMode)
              Positioned(
                bottom: 80, 
                left: 0,
                right: 0,
                child: _buildSelectionToolbar(),
              ),

            const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFunctionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Image.asset(
              'assets/images/icon_camera.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              _takePicture(currentAlbum.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening camera...')),
              );
            },
          ),

          IconButton(
            icon: Image.asset(
              'assets/images/icon_folder.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              _pickFromGallery(currentAlbum.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Importing photos...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            currentAlbum.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'ComicNeue',
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: currentAlbum.photos.length,
              itemBuilder: (context, index) {
                String formattedDate =
                    '${currentAlbum.photos[index].date.day.toString().padLeft(2, '0')}/${currentAlbum.photos[index].date.month.toString().padLeft(2, '0')}/${currentAlbum.photos[index].date.year}';

                return GestureDetector(
                  onTap: () {
                    if (isSelectionMode) {
                      setState(() {
                        selectedPhotos[index] = !selectedPhotos[index];
                        if (!selectedPhotos.contains(true)) {
                          isSelectionMode = false;
                        }
                      });
                    } else {
                      _showFullScreenImage(
                        currentAlbum.photos[index].imagePath,
                      );
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      isSelectionMode = true;
                      selectedPhotos = List.generate(
                        currentAlbum.photos.length,
                        (i) => i == index,
                      );
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(7),
                                ),
                                child: Image.file(
                                  File(currentAlbum.photos[index].imagePath),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/album/placeholder_image.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade700,
                                  fontFamily: 'ComicNeue',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isSelectionMode)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color:
                                  selectedPhotos[index]
                                      ? Colors.blue
                                      : Colors.grey.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child:
                                selectedPhotos[index]
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                    : null,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load image: $error',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildSelectionToolbar() {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Image.asset(
              'assets/images/icon_delete.png',
              width: 28,
              height: 28,
            ),
            onPressed: () {
              _deleteSelectedPhotos();
            },
          ),

          IconButton(
            icon: Image.asset(
              'assets/images/icon_move.png',
              width: 28,
              height: 28,
            ),
            onPressed: () {
              _showMovePhotosDialog();
            },
          ),
        ],
      ),
    );
  }

  void _deleteSelectedPhotos() async {
    DatabaseHandler db = DatabaseHandler();

    try {
      List<int> idsToDelete = [];
      for (int i = 0; i < selectedPhotos.length; i++) {
        if (selectedPhotos[i]) {
          idsToDelete.add(currentAlbum.photos[i].id);
        }
      }

      for (int id in idsToDelete) {
        await db.deleteImage(id);
      }

      for (int i = selectedPhotos.length - 1; i >= 0; i--) {
        if (selectedPhotos[i]) {
          currentAlbum.photos.removeAt(i);
        }
      }

      setState(() {
        isSelectionMode = false;
        selectedPhotos = List.generate(
          currentAlbum.photos.length,
          (i) => false,
        );
      });
    } catch (e) {
      print('Error deleting images: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting images: $e')));
    }
    Navigator.pop(context, widget.albums);
  }

  void _showMovePhotosDialog() {
    int? selectedAlbumIndex;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Text(
                  'Move Photos',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select destination album:',
                        style: TextStyle(fontFamily: 'ComicNeue'),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.albums.length,
                          itemBuilder: (context, index) {
                            if (widget.albums[index].id == currentAlbum.id) {
                              return Container();
                            }

                            return RadioListTile<int>(
                              title: Text(
                                widget.albums[index].name,
                                style: const TextStyle(fontFamily: 'ComicNeue'),
                              ),
                              value: index,
                              groupValue: selectedAlbumIndex,
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedAlbumIndex = value;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        color: Colors.grey,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF729996),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Move',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      if (selectedAlbumIndex != null) {
                        _moveSelectedPhotos(selectedAlbumIndex!);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              );
            },
          ),
    );
  }

  void _moveSelectedPhotos(int destinationAlbumIndex) async {
    Album destinationAlbum = widget.albums[destinationAlbumIndex];
    DatabaseHandler db = DatabaseHandler();

    try {
      List<int> idsToMove = [];
      List<Photo> photosToMove = [];
      for (int i = 0; i < selectedPhotos.length; i++) {
        if (selectedPhotos[i]) {
          idsToMove.add(currentAlbum.photos[i].id);
          photosToMove.add(currentAlbum.photos[i]);
        }
      }

      await db.movePhotosToAlbum(idsToMove, destinationAlbum.id);

      destinationAlbum.photos.addAll(photosToMove);

      for (int i = selectedPhotos.length - 1; i >= 0; i--) {
        if (selectedPhotos[i]) {
          currentAlbum.photos.removeAt(i);
        }
      }

      setState(() {
        isSelectionMode = false;
        selectedPhotos = List.generate(
          currentAlbum.photos.length,
          (i) => false,
        );
      });
    } catch (e) {
      print('Error moving images: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error moving images: $e')));
    }
    Navigator.pop(context, widget.albums);
  }
}
