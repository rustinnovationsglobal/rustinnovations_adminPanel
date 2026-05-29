import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> Insert(String tableName, Map<String, dynamic> data) async {
  try {
    final supabase = Supabase.instance.client;
    await supabase.from(tableName).insert(data);
  } on PostgrestException catch (e) {
    if (kDebugMode) {
      print(e.details);
    }
    return;
  }
}

Future<List<Map<String, dynamic>>> Read(String tableName) async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase.from(tableName).select();
    return List<Map<String, dynamic>>.from(response);
  } on PostgrestException catch (e) {
    if (kDebugMode) {
      print(e.details);
    }
    return [];
  }
}

/// [id] – when provided the UPDATE is scoped to that row only (recommended).
/// Without [id] the update affects every row in the table.
Future<void> Update(String name, Map<String, dynamic> data,
    {String? id}) async {
  try {
    final supabase = Supabase.instance.client;
    if (id != null) {
      await supabase.from(name).update(data).eq('id', id);
    } else {
      await supabase.from(name).update(data);
    }
  } on PostgrestException catch (e) {
    if (kDebugMode) {
      print(e.details);
    }
    return;
  }
}