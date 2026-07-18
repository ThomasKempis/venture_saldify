import 'dart:typed_data';

class SmxAuthUser {
  final String provider;
  final String providerId;
  final String email;
  final String displayName;
  final String? photoUrl;
  final Uint8List? imageBytes;

  const SmxAuthUser({
    required this.provider,
    required this.providerId,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.imageBytes,
  });

  SmxAuthUser copyWith({Uint8List? imageBytes}) {
    return SmxAuthUser(
      provider: provider,
      providerId: providerId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }
}
