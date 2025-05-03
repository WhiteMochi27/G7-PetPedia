// Contributed by: Tong Qian Ru

import 'package:flutter/material.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/models/album.dart';
import 'package:petpedia/models/photo.dart';
import 'package:petpedia/view/pet_profile_page/photo_grid_view.dart';
import 'package:petpedia/database/database_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AlbumListView extends StatefulWidget {
  final int petId;
  const AlbumListView({super.key, required this.petId});
  @override
  State<AlbumListView> createState() => _AlbumListViewState();
}

class _AlbumListViewState extends State<AlbumListView> {
  List<Album> albums = [];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _takePicture(int albumId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      try {
        DatabaseHandler db = DatabaseHandler();

        final allPhotosIndex = albums.indexWhere(
          (album) => album.name == "All photos",
        );
        if (allPhotosIndex == -1) {
          return; 
        }

        final allPhotosId = albums[allPhotosIndex].id;
        final imageData = {
          'album_id': allPhotosId,
          'image_url': image.path,
          'date_added': db.formatDateForDb(DateTime.now()),
          'caption': null,
        };

        int imageId = await db.insertImage(imageData);

        setState(() {
          albums[allPhotosIndex].photos.add(
            Photo(id: imageId, date: DateTime.now(), imagePath: image.path),
          );
        });

        if (albumId != allPhotosId) {
          final albumImageData = {
            'album_id': albumId,
            'image_url': image.path,
            'date_added': db.formatDateForDb(DateTime.now()),
            'caption': null,
          };

          await db.insertImage(albumImageData);

          setState(() {
            final albumIndex = albums.indexWhere(
              (album) => album.id == albumId,
            );
            if (albumIndex != -1) {
              albums[albumIndex].photos.add(
                Photo(id: imageId, date: DateTime.now(), imagePath: image.path),
              );
            }
          });
        }
      } catch (e) {
        print('Error saving image: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
      }
    }
  }

  Future<void> _pickFromGallery(int albumId) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      try {
        DatabaseHandler db = DatabaseHandler();
        List<Photo> newPhotos = [];
        final allPhotosIndex = albums.indexWhere(
          (album) => album.name == "All photos",
        );

        // Save each image to database
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

          if (allPhotosIndex != -1 && albumId != albums[allPhotosIndex].id) {
            final allPhotosImageData = {
              'album_id': albums[allPhotosIndex].id,
              'image_url': image.path,
              'date_added': db.formatDateForDb(DateTime.now()),
              'caption': null,
            };

            int allPhotosImageId = await db.insertImage(allPhotosImageData);

            albums[allPhotosIndex].photos.add(
              Photo(
                id: allPhotosImageId,
                date: DateTime.now(),
                imagePath: image.path,
              ),
            );
          }
        }

        setState(() {
          final albumIndex = albums.indexWhere((album) => album.id == albumId);
          if (albumIndex != -1) {
            albums[albumIndex].photos.addAll(newPhotos);
          }
        });
      } catch (e) {
        print('Error adding images: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding images: $e')));
      }
    }
  }

  Future<void> _loadAlbums() async {
    try {
      final int petId =
          widget.petId; 

      DatabaseHandler db = DatabaseHandler();
      final albumsData = await db.getAlbumsForPet(petId);

      List<Album> loadedAlbums = [];
      for (var albumData in albumsData) {
        int albumId = albumData['album_id']; 

        final photosData = await db.getImagesForAlbum(
          albumId,
        );

        List<Photo> photos =
            photosData.map((photoData) {
              return Photo(
                id: photoData['image_id'],
                date:
                    db.parseDbDate(photoData['date_added']) ??
                    DateTime.now(), 
                imagePath:
                    photoData['image_url'], 
              );
            }).toList();

        loadedAlbums.add(
          Album(id: albumId, name: albumData['name'], photos: photos),
        );
      }

      if (!loadedAlbums.any((album) => album.name == "All photos")) {
        final allPhotosData = {
          'pet_id': petId,
          'name': 'All photos',
          'created_date': db.formatDateForDb(DateTime.now()),
        };

        int allPhotosAlbumId = await db.insertAlbum(allPhotosData);

        List<Photo> allPhotos = [];
        for (var album in loadedAlbums) {
          allPhotos.addAll(album.photos);
        }

        loadedAlbums.insert(
          0,
          Album(id: allPhotosAlbumId, name: "All photos", photos: allPhotos),
        );
      }

      setState(() {
        albums = loadedAlbums;
      });
    } catch (e) {
      print('Error loading albums: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading albums: $e')));
    }
  }

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
            // Header
            const PageTitle(
              icon: 'assets/images/icon_album.png',
              title: 'SnapPaws',
              subtitle: 'Pet Album',
            ),

            Positioned(
              top: 100,
              left: 15,
              child: IconButton(
                icon: Image.asset('assets/images/icon_back.png'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // Content area
            Positioned.fill(
              top: 100,
              child: Column(
                children: [
                  _buildTopFunctionButtons(),

                  Expanded(child: _buildAlbumGrid()),
                ],
              ),
            ),

            const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildTopFunctionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddAlbumDialog();
            },
          ),

          IconButton(
            icon: Image.asset(
              'assets/images/icon_camera.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              _takePicture(albums[0].id);
            },
          ),

          IconButton(
            icon: Image.asset(
              'assets/images/icon_folder.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              if (albums.isNotEmpty && albums[0].name == "All photos") {
                if (albums.length > 1) {
                  _pickFromGallery(albums[1].id);
                } else {
                  _showAddAlbumWithGalleryDialog();
                }
              } else if (albums.isNotEmpty) {
                _pickFromGallery(albums[0].id);
              } else {
                _showAddAlbumWithGalleryDialog();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: .8,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PhotoGridView(album: albums[index], albums: albums),
                ),
              ).then((updatedAlbums) {
                if (updatedAlbums != null) {
                  setState(() {
                    albums = updatedAlbums;
                  });
                }
              });
              ;
            },
            onLongPress: () {
              if (albums[index].name != "All photos") {
                _showDeleteAlbumDialog(index);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child:
                          albums[index].photos.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.file(
                                  File(albums[index].photos[0].imagePath),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/album/placeholder_image.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              )
                              : const Icon(
                                Icons.photo_album,
                                size: 40,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  albums[index].name,
                  style: const TextStyle(
                    fontFamily: 'ComicNeue',
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${albums[index].photos.length}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'ComicNeue',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddAlbumDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              'Add Album',
              style: TextStyle(
                fontFamily: 'ComicNeue',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Album Name',
                hintStyle: const TextStyle(fontFamily: 'ComicNeue'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(fontFamily: 'ComicNeue'),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'ComicNeue', color: Colors.grey),
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
                  'Save',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    try {
                      // Save album to database
                      DatabaseHandler db = DatabaseHandler();
                      final albumData = {
                        'pet_id': widget.petId,
                        'name': controller.text,
                        'created_date': db.formatDateForDb(DateTime.now()),
                      };

                      int albumId = await db.insertAlbum(albumData);

                      setState(() {
                        albums.add(
                          Album(id: albumId, name: controller.text, photos: []),
                        );
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      print('Error creating album: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating album: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  void _showDeleteAlbumDialog(int albumIndex) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              'Delete Album',
              style: TextStyle(
                fontFamily: 'ComicNeue',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${albums[albumIndex].name}"?',
              style: const TextStyle(fontFamily: 'ComicNeue'),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'ComicNeue', color: Colors.grey),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  DatabaseHandler db = DatabaseHandler();
                  await db.deleteAlbum(albums[albumIndex].id);
                  setState(() {
                    albums.removeAt(albumIndex);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _showAddAlbumWithGalleryDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              'Add Album & Import Photos',
              style: TextStyle(
                fontFamily: 'ComicNeue',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Album Name',
                hintStyle: const TextStyle(fontFamily: 'ComicNeue'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(fontFamily: 'ComicNeue'),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'ComicNeue', color: Colors.grey),
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
                  'Create & Import Photos',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    try {
                      DatabaseHandler db = DatabaseHandler();
                      final albumData = {
                        'pet_id': widget.petId,
                        'name': controller.text,
                        'created_date': db.formatDateForDb(DateTime.now()),
                      };

                      int albumId = await db.insertAlbum(albumData);

                      setState(() {
                        albums.add(
                          Album(id: albumId, name: controller.text, photos: []),
                        );
                      });

                      Navigator.pop(context);
                      _pickFromGallery(albumId);
                    } catch (e) {
                      print('Error creating album: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating album: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }
}
