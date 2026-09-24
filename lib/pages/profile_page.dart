import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../session_manager.dart';
import 'messages_page.dart';
import 'add_friends_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  final sessionManager = SessionManager();
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? userProfile;
  List<Map<String, dynamic>> userPublications = [];
  int friendsCount = 0;

  late StreamSubscription<List<Map<String, dynamic>>> _profileSub;
  late StreamSubscription<List<Map<String, dynamic>>> _pubSub;

  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    if (user == null) return;

    currentUserId = user.id;
    sessionManager.goOnline();

    _profileSub = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', currentUserId)
        .listen((profiles) {
      if (!mounted || profiles.isEmpty) return;
      setState(() {
        userProfile = profiles.first;
      });
    });

    _pubSub = supabase
        .from('publications')
        .stream(primaryKey: ['id'])
        .eq('profile_id', currentUserId)
        .order('created_at', ascending: false)
        .listen((pubs) async {
      for (var p in pubs) {
        final owner = await supabase
            .from('profiles')
            .select()
            .eq('id', p['profile_id'])
            .single();
        p['owner'] = owner;
      }
      if (!mounted) return;
      setState(() {
        userPublications = pubs;
      });
    });

    _fetchFriendsCount();
  }

  Future<void> _fetchFriendsCount() async {
    final data = await supabase
        .from('friends')
        .select()
        .eq('user_id', currentUserId);

    if (!mounted) return;
    setState(() {
      friendsCount = data.length;
    });
  }

  @override
  void dispose() {
    _profileSub.cancel();
    _pubSub.cancel();
    super.dispose();
  }

  Future<void> signOut(BuildContext context) async {
    await sessionManager.goOffline();
    await supabase.auth.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  String relativeTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inHours < 1) return "${diff.inMinutes} min";
    if (diff.inHours < 24) return "${diff.inHours} h";
    return "${diff.inDays} j";
  }

  // =======================
  // 🔥 CHANGEMENT AVATAR
  // =======================
  Future<void> _changeProfilePicture() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final fileName =
        "$currentUserId-${DateTime.now().millisecondsSinceEpoch}.jpg";

    if (kIsWeb) {
      // ✅ Web: lire les octets
      final Uint8List bytes = await picked.readAsBytes();
      await supabase.storage.from('profile-pictures').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
    } else {
      // ✅ Mobile/Desktop: File
      final file = File(picked.path);
      await supabase.storage.from('profile-pictures').upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
    }

    // Mise à jour du profil
    await supabase
        .from('profiles')
        .update({'avatar_url': fileName})
        .eq('id', currentUserId);

    // Le stream supabase mettra à jour automatiquement l'UI
  }


  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MessagesPage()),
      );
    } else if (index == 2) {
      return;
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AddFriendsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    final isOnline = userProfile!['online'] ?? false;

    final avatarUrl = userProfile!['avatar_url'] != null
        ? supabase.storage
        .from('profile-pictures')
        .getPublicUrl(userProfile!['avatar_url'])
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => signOut(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 22),
                GestureDetector(
                  onTap: _changeProfilePicture,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person,
                        size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 32),
                Column(
                  children: [
                    const Text(
                      "Amis",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$friendsCount",
                      style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "@${userProfile!['username']}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Prénom : ${userProfile!['prenom'] ?? ''}",
                    style: const TextStyle(fontSize: 18)),
                Text("Nom : ${userProfile!['nom'] ?? ''}",
                    style: const TextStyle(fontSize: 18)),
                Text("Email : ${userProfile!['email'] ?? ''}",
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: _onNavTap,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add Friends',
          ),
        ],
      ),
    );
  }
}
