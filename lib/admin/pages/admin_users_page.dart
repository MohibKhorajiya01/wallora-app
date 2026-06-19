import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/snackbar_utils.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  Future<void> _deleteUser(String docId, String name) async {
    // Step 1 Verification
    bool? step1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Remove User?", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to remove $name?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Proceed", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (step1 != true) return;

    // Step 2 Final Verification
    if (!mounted) return;
    bool? step2 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Final Warning", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("This action is IRREVERSIBLE. $name's data will be permanently deleted. Are you REALLY sure?", style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete Permanently", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (step2 == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(docId).delete();
        if (mounted) SnackBarUtils.showMsg(context, "User deleted successfully", isError: false);
      } catch (e) {
        if (mounted) SnackBarUtils.showMsg(context, "Failed to delete user", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Registered Users", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white24));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No users found.", style: TextStyle(color: Colors.white54, fontSize: 16)),
                );
              }
              
              var docs = snapshot.data!.docs.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return data['isAdmin'] != true;
              }).toList();

              if (docs.isEmpty) {
                return const Center(
                  child: Text("No normal users found.", style: TextStyle(color: Colors.white54, fontSize: 16)),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var doc = docs[index];
                  var data = doc.data() as Map<String, dynamic>;
                  String name = data['name'] ?? 'Unknown User';
                  String email = data['email'] ?? 'No Email';
                  Timestamp? createdAt = data['createdAt'] as Timestamp?;
                  
                  String dateStr = "Just now";
                  if (createdAt != null) {
                    DateTime date = createdAt.toDate();
                    dateStr = "${date.day}/${date.month}/${date.year}";
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[900],
                          radius: 25,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?', 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(email, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Joined", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                          onPressed: () => _deleteUser(doc.id, name),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
