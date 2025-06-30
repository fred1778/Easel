import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "login.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easel/auth.dart';
import 'package:flutter/material.dart';

// Handles submitting images to the backend

class SubmissionManager {
  static prepareSubmission() {
    print(BootManager.currentUserProfile?.id ?? "USER ERROR");
  }
}
