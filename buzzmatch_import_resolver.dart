// buzzmatch_import_resolver.dart
// Save this file in your project root and run with:
// dart buzzmatch_import_resolver.dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('BuzzMatch Import Resolver Tool');
  print('------------------------------');

  // Get the current directory
  final Directory currentDir = Directory.current;
  final Directory libDir = Directory('${currentDir.path}/lib');

  if (!libDir.existsSync()) {
    print(
        'Error: lib directory not found. Make sure you run this script from the project root.');
    return;
  }

  print('Scanning for Dart files...');
  final List<FileSystemEntity> libContents = libDir.listSync(recursive: true);

  // Map to track missing imports
  final Map<String, List<String>> missingImports = {};
  final Set<String> existingFiles = {};

  // First, collect all existing Dart files
  print('Collecting existing Dart files...');
  for (final entity in libContents) {
    if (entity is File && entity.path.endsWith('.dart')) {
      existingFiles.add(entity.path.replaceAll('${currentDir.path}/', ''));
    }
  }

  print('Found ${existingFiles.length} Dart files.');

  // Now check imports in each file
  print('Analyzing imports...');
  for (final entity in libContents) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final String content = await entity.readAsString();
      final List<String> lines = LineSplitter.split(content).toList();

      for (final line in lines) {
        if (line.trim().startsWith('import \'') && line.contains('.dart')) {
          // Extract the import path - fixed regex
          final RegExp regex = RegExp(r"import ['](.+?)[']");
          final match = regex.firstMatch(line);

          if (match != null) {
            String importPath = match.group(1)!;

            // Handle relative imports
            if (importPath.startsWith('./') || importPath.startsWith('../')) {
              // Convert relative path to absolute path based on current file
              final File currentFile = entity;
              final String dirPath = currentFile.parent.path;
              final String resolvedPath =
                  resolveRelativePath(dirPath, importPath);
              importPath = resolvedPath.replaceAll('${currentDir.path}/', '');
            } else if (!importPath.startsWith('package:') &&
                !importPath.startsWith('dart:')) {
              // Handle lib/ imports
              if (!importPath.startsWith('lib/')) {
                importPath = 'lib/$importPath';
              }
            }

            // Only check our app files, not package imports
            if (!importPath.startsWith('package:') &&
                !importPath.startsWith('dart:') &&
                !existingFiles.contains(importPath)) {
              // Add to missing imports
              if (!missingImports.containsKey(entity.path)) {
                missingImports[entity.path] = [];
              }
              missingImports[entity.path]!.add(importPath);
            }
          } else if (line.trim().startsWith('import "') &&
              line.contains('.dart')) {
            // Also handle double quotes
            final RegExp regex = RegExp(r'import "(.+?)"');
            final match = regex.firstMatch(line);

            if (match != null) {
              String importPath = match.group(1)!;

              // Same handling as above
              if (importPath.startsWith('./') || importPath.startsWith('../')) {
                final File currentFile = entity;
                final String dirPath = currentFile.parent.path;
                final String resolvedPath =
                    resolveRelativePath(dirPath, importPath);
                importPath = resolvedPath.replaceAll('${currentDir.path}/', '');
              } else if (!importPath.startsWith('package:') &&
                  !importPath.startsWith('dart:')) {
                if (!importPath.startsWith('lib/')) {
                  importPath = 'lib/$importPath';
                }
              }

              if (!importPath.startsWith('package:') &&
                  !importPath.startsWith('dart:') &&
                  !existingFiles.contains(importPath)) {
                if (!missingImports.containsKey(entity.path)) {
                  missingImports[entity.path] = [];
                }
                missingImports[entity.path]!.add(importPath);
              }
            }
          }
        }
      }
    }
  }

  // Print results
  print('\n===== ANALYSIS RESULTS =====');
  if (missingImports.isEmpty) {
    print('No missing imports found! Your project structure is looking good.');
  } else {
    print(
        '\nFound ${missingImports.values.expand((x) => x).toSet().length} unique missing imports in ${missingImports.length} files:');

    missingImports.forEach((file, imports) {
      print('\nIn file: ${file.replaceAll('${currentDir.path}/', '')}');
      for (final importPath in imports) {
        print('  → Missing: $importPath');
      }
    });

    // Ask to create placeholder files
    print(
        '\nWould you like to create placeholder files for missing imports? (y/n)');
    final input = stdin.readLineSync()?.toLowerCase();

    if (input == 'y') {
      int created = 0;

      // Collect all unique missing imports
      final Set<String> allMissingImports = {};
      for (var imports in missingImports.values) {
        allMissingImports.addAll(imports);
      }

      // Create each missing file
      for (final path in allMissingImports) {
        if (!path.startsWith('package:') && !path.startsWith('dart:')) {
          final File file = File(path);

          // Create directories if they don't exist
          file.parent.createSync(recursive: true);

          if (!file.existsSync()) {
            // Generate placeholder content
            final String filename = path.split('/').last.split('.').first;
            String className = '';

            // Extract potential class name from filename (convert snake_case to PascalCase)
            if (filename.contains('_')) {
              className = filename
                  .split('_')
                  .map((part) => part.isNotEmpty
                      ? '${part[0].toUpperCase()}${part.substring(1)}'
                      : '')
                  .join('');
            } else {
              className = filename.isNotEmpty
                  ? '${filename[0].toUpperCase()}${filename.substring(1)}'
                  : 'Generated';
            }

            // Create placeholder file based on context (file location and name)
            String content = generatePlaceholderContent(path, className);
            file.writeAsStringSync(content);
            created++;
            print('Created: $path');
          }
        }
      }

      print('\nCreated $created missing files.');
      print(
          'Run "flutter analyze" to check if all import issues are resolved.');
    }
  }
}

String resolveRelativePath(String basePath, String relativePath) {
  final List<String> parts = basePath.split('/');
  final List<String> resultParts = [...parts];

  // Handle relative path segments
  final List<String> relativeSegments = relativePath.split('/');
  for (final segment in relativeSegments) {
    if (segment == '..') {
      if (resultParts.isNotEmpty) {
        resultParts.removeLast();
      }
    } else if (segment != '.' && segment.isNotEmpty) {
      resultParts.add(segment);
    }
  }

  return resultParts.join('/');
}

String generatePlaceholderContent(String path, String className) {
  // Different templates based on file path/name
  if (path.contains('bindings') && path.contains('_binding.dart')) {
    return '''
import 'package:get/get.dart';
// TODO: Import the controller for this binding

class $className extends Bindings {
  @override
  void dependencies() {
    // TODO: Initialize controller
    // Get.put<YourController>(YourController());
  }
}
''';
  } else if (path.contains('controllers') &&
      path.contains('_controller.dart')) {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class $className extends GetxController {
  // TODO: Implement controller
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // TODO: Initialize controller
  }
}
''';
  } else if (path.contains('views') && path.contains('_view.dart')) {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// TODO: Import controller

class $className extends GetView<YourController> {
  const $className({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${className.replaceAll('View', '')}'),
      ),
      body: Center(
        child: Text('$className - Implementation Pending'),
      ),
    );
  }
}
''';
  } else if (path.contains('models') && path.contains('_model.dart')) {
    return '''
import 'package:cloud_firestore/cloud_firestore.dart';

class $className {
  final String id;
  
  $className({
    required this.id,
  });
  
  // Factory method to create from Firestore
  factory $className.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return $className(
      id: doc.id,
    );
  }
  
  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      // Add properties here
    };
  }
}
''';
  } else if (path.contains('widgets') && path.endsWith('.dart')) {
    return '''
import 'package:flutter/material.dart';

class $className extends StatelessWidget {
  const $className({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: Implement widget
      child: Text('$className Widget'),
    );
  }
}
''';
  } else if (path.contains('utils') && path.endsWith('.dart')) {
    return '''
// Utility functions for $className

class $className {
  // Private constructor to prevent instantiation
  $className._();
  
  // Add utility methods here
  static String exampleMethod() {
    return 'Example';
  }
}
''';
  } else if (path.contains('services') && path.endsWith('.dart')) {
    return '''
import 'package:get/get.dart';

class $className extends GetxService {
  static $className get to => Get.find<$className>();
  
  // Initialize service
  Future<$className> init() async {
    // TODO: Initialize service
    return this;
  }
  
  // Add service methods here
}
''';
  } else {
    // Generic placeholder
    return '''
// ${path.split('/').last} - Placeholder file
// TODO: Replace with actual implementation

// This is a placeholder file created by the BuzzMatch Import Resolver
// Replace this with the actual implementation
''';
  }
}
