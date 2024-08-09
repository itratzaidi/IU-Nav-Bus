import 'package:firebase_storage/firebase_storage.dart';
import 'package:iu_nav_bus/global.dart';

class FirestorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<List<String>> fetchImagesFromAdsFolder() async {
    try {
      // Reference to the 'ads' folder
      final ListResult result = await storage.ref('ads').listAll();

      // Get the download URLs for each item in the folder
      final List<String> urls = await Future.wait(
          result.items.map((Reference ref) => ref.getDownloadURL()));
      adsUrls = urls;
      return urls;
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  Future<String?> fetchImageUrlByFileName(String fileName) async {
    try {
      // Reference to the file by name
      final Reference fileRef = storage.ref('ads/$fileName');

      // Get the download URL for the file
      final String url = await fileRef.getDownloadURL();
      return url;
    } catch (e) {
      print('Error fetching image URL for $fileName: $e');
      return null;
    }
  }
}
