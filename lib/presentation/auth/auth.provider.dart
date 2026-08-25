import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/secure_storage_service.dart';
import '../../data/datasources/mock_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/task_repository.dart';

final mockDataSourceProvider = Provider<MockDataSource>((ref) {
  return MockDataSource();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(mockDataSourceProvider),
  );
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) => ProjectRepositoryImpl(ref.watch(mockDataSourceProvider)));
final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepositoryImpl(ref.watch(mockDataSourceProvider)));
