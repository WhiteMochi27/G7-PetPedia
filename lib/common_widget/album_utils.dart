import 'package:flutter/material.dart';

// Common dialog for adding an album
void showAddAlbumDialog(BuildContext context, Function(String) onSave) {
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
            style: TextStyle(fontFamily: 'ComicNeue', color: Colors.white),
          ),
          onPressed: () {
            if (controller.text.isNotEmpty) {
              onSave(controller.text);
              Navigator.pop(context);
            }
          },
        ),
      ],
    ),
  );
}

// Common dialog for deleting an album
void showDeleteAlbumDialog(BuildContext context, String albumName, Function onDelete) {
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
        'Are you sure you want to delete "$albumName"?',
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
            onDelete();
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}