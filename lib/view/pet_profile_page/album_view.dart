import 'package:flutter/material.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';

class AlbumView extends StatefulWidget {
  const AlbumView({super.key});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  // Track current view (Albums or Photos in specific album)
  bool isAlbumListView = true;
  String currentAlbumTitle = "All photos";
  
  // Sample albums data
  List<Album> albums = [
    Album(
      name: "All photos",
      photos: [
        Photo(date: DateTime(2025, 3, 9)),
        Photo(date: DateTime(2025, 3, 1)),
        Photo(date: DateTime(2025, 2, 27)),
        Photo(date: DateTime(2025, 3, 9)),
        Photo(date: DateTime(2023, 9, 9)),
        Photo(date: DateTime(2023, 8, 31)),
      ],
    ),
    Album(
      name: "Birthday",
      photos: [
        Photo(date: DateTime(2024, 6, 15)),
        Photo(date: DateTime(2024, 6, 15)),
      ],
    ),
    Album(
      name: "Favourites",
      photos: [
        Photo(date: DateTime(2024, 7, 20)),
        Photo(date: DateTime(2024, 8, 12)),
      ],
    ),
  ];
  
  // Selection mode variables
  bool isSelectionMode = false;
  List<bool> selectedPhotos = [];

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
            // Header
            PageTitle(
              icon: 'assets/images/icon_album.png',
              title: 'SnapPaws',
              subtitle: 'Pet Album',
            ),

            // Back button
            isAlbumListView ? Container() : Positioned(
              top: 15,
              left: 15,
              child: IconButton(
                icon: Image.asset(
                  'assets/images/icon_back.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {
                  setState(() {
                    isAlbumListView = true;
                    isSelectionMode = false;
                  });
                },
              ),
            ),

            // Content area
            Positioned.fill(
              top: 100,
              child: Column(
                children: [
                  // Function buttons at top
                  _buildTopFunctionButtons(),
                  
                  // Main content - either album list or photos grid
                  Expanded(
                    child: isAlbumListView 
                      ? _buildAlbumGrid() 
                      : _buildPhotoGrid(),
                  ),
                ],
              ),
            ),

            // Selection mode bottom toolbar
            if (isSelectionMode)
              Positioned(
                bottom: 80,  // Position above the HomeButton
                left: 0,
                right: 0,
                child: _buildSelectionToolbar(),
              ),

            // Home button at bottom
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
          // Add album button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddAlbumDialog();
            },
          ),
          
          // Camera button
          IconButton(
            icon: Image.asset(
              'assets/images/icon_camera.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              // TODO: Implement camera access
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening camera...'))
              );
            },
          ),
          
          // Folder button
          IconButton(
            icon: Image.asset(
              'assets/images/icon_folder.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              // TODO: Implement gallery access
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Importing photos...'))
              );
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
          childAspectRatio: 0.9,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                isAlbumListView = false;
                currentAlbumTitle = albums[index].name;
                selectedPhotos = List.generate(
                  albums[index].photos.length, 
                  (i) => false
                );
              });
            },
            onLongPress: () {
              // Show delete album option
              if (albums[index].name != "All photos") {
                _showDeleteAlbumDialog(index);
              }
            },
            child: Column(
              children: [
                // Album thumbnail
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: albums[index].photos.isNotEmpty
                      ? Image.asset(
                          'assets/album/placeholder_image.png',
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.photo_album, size: 40, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 4),
                // Album name
                Text(
                  albums[index].name,
                  style: const TextStyle(
                    fontFamily: 'ComicNeue',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Photos count
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

  Widget _buildPhotoGrid() {
    // Get current album
    Album currentAlbum = albums.firstWhere(
      (album) => album.name == currentAlbumTitle,
      orElse: () => albums.first,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Album title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            currentAlbumTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'ComicNeue',
            ),
          ),
        ),
        
        // Photos grid
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
                String formattedDate = '${currentAlbum.photos[index].date.day.toString().padLeft(2, '0')}/${currentAlbum.photos[index].date.month.toString().padLeft(2, '0')}/${currentAlbum.photos[index].date.year}';
                
                return GestureDetector(
                  onTap: () {
                    if (isSelectionMode) {
                      setState(() {
                        selectedPhotos[index] = !selectedPhotos[index];
                        // Exit selection mode if nothing is selected
                        if (!selectedPhotos.contains(true)) {
                          isSelectionMode = false;
                        }
                      });
                    } else {
                      // View photo (not implemented in this sample)
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      isSelectionMode = true;
                      selectedPhotos = List.generate(
                        currentAlbum.photos.length, 
                        (i) => i == index
                      );
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo
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
                                child: Image.asset(
                                  'assets/album/placeholder_image.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
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
                      
                      // Selection indicator
                      if (isSelectionMode)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: selectedPhotos[index] 
                                ? Colors.blue 
                                : Colors.grey.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: selectedPhotos[index]
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
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

  Widget _buildSelectionToolbar() {
    return Container(
      height: 60,
      color: Colors.white.withOpacity(0.9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Delete button
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
          
          // Move button
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

  void _showAddAlbumDialog() {
    TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Add Album',
          style: TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Album Name',
            hintStyle: TextStyle(fontFamily: 'ComicNeue'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          style: TextStyle(fontFamily: 'ComicNeue'),
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
              style: TextStyle(fontFamily: 'ComicNeue', color: Colors.white),
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  albums.add(Album(name: controller.text, photos: []));
                });
                Navigator.pop(context);
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Delete Album',
          style: TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.bold),
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
              style: TextStyle(fontFamily: 'ComicNeue', color: Colors.white),
            ),
            onPressed: () {
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

  void _deleteSelectedPhotos() {
    Album currentAlbum = albums.firstWhere(
      (album) => album.name == currentAlbumTitle,
    );
    
    // Remove selected photos in reverse order to avoid index issues
    for (int i = selectedPhotos.length - 1; i >= 0; i--) {
      if (selectedPhotos[i]) {
        currentAlbum.photos.removeAt(i);
      }
    }
    
    setState(() {
      isSelectionMode = false;
      selectedPhotos = List.generate(currentAlbum.photos.length, (i) => false);
    });
  }

  void _showMovePhotosDialog() {
    int? selectedAlbumIndex;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Move Photos',
          style: TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.bold),
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
              ListView.builder(
                shrinkWrap: true,
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  // Skip current album
                  if (albums[index].name == currentAlbumTitle) {
                    return Container();
                  }
                  
                  return RadioListTile<int>(
                    title: Text(
                      albums[index].name,
                      style: const TextStyle(fontFamily: 'ComicNeue'),
                    ),
                    value: index,
                    groupValue: selectedAlbumIndex,
                    onChanged: (value) {
                      setState(() {
                        selectedAlbumIndex = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
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
              'Move',
              style: TextStyle(fontFamily: 'ComicNeue', color: Colors.white),
            ),
            onPressed: () {
              if (selectedAlbumIndex != null) {
                _moveSelectedPhotos(selectedAlbumIndex!);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _moveSelectedPhotos(int destinationAlbumIndex) {
    Album sourceAlbum = albums.firstWhere(
      (album) => album.name == currentAlbumTitle,
    );
    Album destinationAlbum = albums[destinationAlbumIndex];
    
    // Move selected photos
    List<Photo> photosToMove = [];
    for (int i = 0; i < selectedPhotos.length; i++) {
      if (selectedPhotos[i]) {
        photosToMove.add(sourceAlbum.photos[i]);
      }
    }
    
    // Add to destination
    destinationAlbum.photos.addAll(photosToMove);
    
    // Remove from source (in reverse order)
    for (int i = selectedPhotos.length - 1; i >= 0; i--) {
      if (selectedPhotos[i]) {
        sourceAlbum.photos.removeAt(i);
      }
    }
    
    setState(() {
      isSelectionMode = false;
      selectedPhotos = List.generate(sourceAlbum.photos.length, (i) => false);
    });
  }
}

// Model classes
class Album {
  String name;
  List<Photo> photos;
  
  Album({required this.name, required this.photos});
}

class Photo {
  DateTime date;
  
  Photo({required this.date});
}