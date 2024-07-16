import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/resources/storage_method.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some Error Occured";
    try {
      String postId = const Uuid().v1();
      String photoUrl =
          await StorageMethod().uploadImageToStorage('posts', file, true);
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (err) {
      print(
        err.toString(),
      );
    }
  }

  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occured";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set(
          {
            'profilePic': profilePic,
            'name': name,
            'uid': uid,
            'text': text,
            'commentId': commentId,
            'datePublished': DateTime.now(),
          },
        );
        res = "success";
      } else {
        res = "Please enter text!";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Deleting a Post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {}
  }

  // Follow user
  Future<void> followUser(String uid, String followUid) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('user').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];
      if (following.contains(followUid)) {
        await _firestore.collection('user').doc(followUid).update(
          {
            'followers': FieldValue.arrayRemove(
              [uid],
            ),
          },
        );

        await _firestore.collection('user').doc(uid).update(
          {
            'following': FieldValue.arrayRemove(
              [followUid],
            ),
          },
        );
      } else {
        if (following.contains(followUid)) {
          await _firestore.collection('user').doc(followUid).update(
            {
              'followers': FieldValue.arrayUnion(
                [uid],
              ),
            },
          );

          await _firestore.collection('user').doc(uid).update(
            {
              'following': FieldValue.arrayUnion(
                [followUid],
              ),
            },
          );
        }
      }
    } catch (err) {
      print(err.toString());
    }
  }

}
