import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/project_model.dart';
import '../../data/models/task_model.dart';
import '../../data/models/user_model.dart';
import '../auth/auth.controller.dart';
import '../auth/auth.provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<List<ProjectModel>>? _projects;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final orgId = ref.read(authControllerProvider).orgId;

    if (orgId == null) {
      _projects = Future.error(
        Exception('No organization is associated with this session.'),
      );
      return;
    }

    _projects = ref
        .read(projectRepositoryProvider)
        .getProjects(orgId);
  }

  void _refresh() {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isAdmin = auth.role == 'org_admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('TaskFlow'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  if (!context.mounted) return;

                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    const SnackBar(
                      content: Text('Profile & settings coming soon.'),
                    ),
                  );
                  break;

                case 'logout':
                  await ref
                      .read(authControllerProvider.notifier)
                      .logout();

                  if (!context.mounted) return;

                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (_) => false,
                  );
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'profile',
                child: Text('Profile & settings'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _projectForm,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Project'),
      ),
      body: FutureBuilder<List<ProjectModel>>(
        future: _projects,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: '${snapshot.error}',
              retry: () => setState(_load),
            );
          }

          final projects = snapshot.data ?? const <ProjectModel>[];

          if (projects.isEmpty) {
            return const _EmptyView(
              icon: Icons.folder_off_outlined,
              text: 'No projects yet',
            );
          }

          final totalTasks = projects.fold<int>(
            0,
            (sum, project) => sum + project.taskCount,
          );

          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _HomeHeader(
                  projectCount: projects.length,
                  totalTasks: totalTasks,
                  activeProjects: projects
                      .where((project) => project.status == 'active')
                      .length,
                ),
                const SizedBox(height: 18),
                ...projects.map(
                  (project) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProjectCard(
                      project: project,
                      isAdmin: isAdmin,
                      orgId: auth.orgId!,
                      onChanged: _refresh,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _projectForm() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final orgId = ref.read(authControllerProvider).orgId;

    if (orgId == null) {
      _showSnack('No organization is associated with this session.');
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New project'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                try {
                  await ref.read(projectRepositoryProvider).createProject(
                        orgId: orgId,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                      );

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext, true);
                } catch (error) {
                  if (!dialogContext.mounted) return;

                  ScaffoldMessenger.maybeOf(dialogContext)
                      ?.showSnackBar(
                        SnackBar(
                          content: Text(
                            error.toString().replaceFirst(
                                  'Exception: ',
                                  '',
                                ),
                          ),
                        ),
                      );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();

    if (!mounted) return;

    if (result == true) {
      _refresh();
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.isAdmin,
    required this.orgId,
    required this.onChanged,
  });

  final ProjectModel project;
  final bool isAdmin;
  final String orgId;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = project.status == 'active';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(
                project: project,
                orgId: orgId,
                isAdmin: isAdmin,
              ),
            ),
          );

          if (!context.mounted) return;
          onChanged();
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primaryContainer,
                      scheme.primary.withValues(alpha: 0.76),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE8F8EE)
                                : const Color(0xFFECEAFD),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Planning',
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF16834B)
                                  : const Color(0xFF5B4AE4),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description.isEmpty
                          ? 'No description'
                          : project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${project.taskCount} tasks',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 15,
                          color: scheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat.MMMd().format(project.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.projectCount,
    required this.totalTasks,
    required this.activeProjects,
  });

  final int projectCount;
  final int totalTasks;
  final int activeProjects;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1B4B),
            const Color(0xFF4F46E5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white70,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your work is moving',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Projects',
                  value: '$projectCount',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Tasks',
                  value: '$totalTasks',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Active',
                  value: '$activeProjects',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.orgId,
    required this.isAdmin,
  });

  final ProjectModel project;
  final String orgId;
  final bool isAdmin;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState
    extends ConsumerState<ProjectDetailScreen> {
  Future<List<TaskModel>>? _tasks;

  String? _status;
  String? _priority;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _tasks = ref
        .read(taskRepositoryProvider)
        .getTasks(widget.project.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          if (widget.isAdmin)
            IconButton(
              tooltip: 'Delete project',
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteProject,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _taskForm,
        icon: const Icon(Icons.add_task),
        label: const Text('Task'),
      ),
      body: FutureBuilder<List<TaskModel>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
              retry: () => setState(_load),
            );
          }

          final allTasks = snapshot.data ?? const <TaskModel>[];

          final filteredTasks = allTasks.where((task) {
            final matchesStatus =
                _status == null || task.status == _status;

            final matchesPriority =
                _priority == null || task.priority == _priority;

            return matchesStatus && matchesPriority;
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(_load);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.project.description.isEmpty
                      ? 'No description'
                      : widget.project.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                _Summary(tasks: allTasks),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Filter(
                      label: 'Status',
                      value: _status,
                      values: const [
                        'todo',
                        'in_progress',
                        'review',
                        'done',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _status = value;
                        });
                      },
                    ),
                    _Filter(
                      label: 'Priority',
                      value: _priority,
                      values: const [
                        'low',
                        'medium',
                        'high',
                        'urgent',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _priority = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (filteredTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 56),
                    child: _EmptyView(
                      icon: Icons.task_alt,
                      text: 'No tasks match these filters',
                    ),
                  )
                else
                  ...filteredTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TaskCard(
                        task: task,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(
                                task: task,
                                orgId: widget.orgId,
                              ),
                            ),
                          );

                          if (!context.mounted) return;
                          setState(_load);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteProject() async {
    final confirmed = await _confirm(
      context,
      'Delete project?',
      'This action cannot be undone.',
    );

    if (!confirmed || !mounted) return;

    try {
      await ref
          .read(projectRepositoryProvider)
          .deleteProject(
            projectId: widget.project.id,
            isAdmin: widget.isAdmin,
          );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      _showSnack(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<void> _taskForm() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    var priority = 'medium';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New task'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Title is required';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                      ),
                      items: const [
                        'low',
                        'medium',
                        'high',
                        'urgent',
                      ]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          priority = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    try {
                      await ref
                          .read(taskRepositoryProvider)
                          .createTask(
                            projectId: widget.project.id,
                            title: titleController.text.trim(),
                            description:
                                descriptionController.text.trim(),
                            priority: priority,
                          );

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext, true);
                    } catch (error) {
                      if (!dialogContext.mounted) return;

                      ScaffoldMessenger.maybeOf(dialogContext)
                          ?.showSnackBar(
                            SnackBar(
                              content: Text(
                                error.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                              ),
                            ),
                          );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();

    if (!mounted) return;

    if (result == true) {
      setState(_load);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.orgId,
  });

  final TaskModel task;
  final String orgId;

  @override
  ConsumerState<TaskDetailScreen> createState() =>
      _TaskDetailScreenState();
}

class _TaskDetailScreenState
    extends ConsumerState<TaskDetailScreen> {
  late TaskModel _task;
  Future<List<UserModel>>? _members;

  @override
  void initState() {
    super.initState();

    _task = widget.task;

    _members = ref
        .read(taskRepositoryProvider)
        .getOrgMembers(widget.orgId);
  }

  Future<void> _save(TaskModel next) async {
    try {
      await ref
          .read(taskRepositoryProvider)
          .updateTask(next);

      if (!mounted) return;

      setState(() {
        _task = next;
      });
    } catch (error) {
      if (!mounted) return;

      _showSnack(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          IconButton(
            tooltip: 'Delete task',
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _task.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            _task.description.isEmpty
                ? 'No description'
                : _task.description,
          ),
          const SizedBox(height: 24),
          _choice(
            label: 'Status',
            current: _task.status,
            values: const [
              'todo',
              'in_progress',
              'review',
              'done',
            ],
            onChanged: (value) {
              _save(
                _task.copyWith(
                  status: value,
                ),
              );
            },
          ),
          _choice(
            label: 'Priority',
            current: _task.priority,
            values: const [
              'low',
              'medium',
              'high',
              'urgent',
            ],
            onChanged: (value) {
              _save(
                _task.copyWith(
                  priority: value,
                ),
              );
            },
          ),
          FutureBuilder<List<UserModel>>(
            future: _members,
            builder: (context, snapshot) {
              final users = snapshot.data ?? const <UserModel>[];

              return DropdownButtonFormField<String?>(
                initialValue: _task.assigneeId,
                decoration: const InputDecoration(
                  labelText: 'Assignee',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Unassigned'),
                  ),
                  ...users.map(
                    (user) => DropdownMenuItem<String?>(
                      value: user.id,
                      child: Text(user.name),
                    ),
                  ),
                ],
                onChanged: (id) async {
                  try {
                    final updated = await ref
                        .read(taskRepositoryProvider)
                        .assignTask(
                          taskId: _task.id,
                          userId: id,
                          orgId: widget.orgId,
                        );

                    if (!mounted) return;

                    setState(() {
                      _task = updated;
                    });
                  } catch (error) {
                    if (!mounted) return;

                    _showSnack(
                      error.toString().replaceFirst(
                            'Exception: ',
                            '',
                          ),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Due ${DateFormat.yMMMd().format(_task.dueDate)}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _choice({
    required String label,
    required String current,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: current,
        decoration: InputDecoration(
          labelText: label,
        ),
        items: values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(
                  value.replaceAll('_', ' '),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await _confirm(
      context,
      'Delete task?',
      'This action cannot be undone.',
    );

    if (!confirmed || !mounted) return;

    try {
      await ref
          .read(taskRepositoryProvider)
          .deleteTask(_task.id);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      _showSnack(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.tasks,
  });

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    final counts = {
      for (final status in [
        'todo',
        'in_progress',
        'review',
        'done',
      ])
        status: tasks
            .where((task) => task.status == status)
            .length,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: counts.entries.map((entry) {
            return Column(
              children: [
                Text(
                  '${entry.value}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  entry.key.replaceAll('_', ' '),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Filter extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String?>(
      hint: Text(label),
      value: value,
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text('All $label'),
        ),
        ...values.map(
          (item) => DropdownMenuItem<String?>(
            value: item,
            child: Text(
              item.replaceAll('_', ' '),
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  final TaskModel task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(task.title),
        subtitle: Text(
          '${task.status.replaceAll('_', ' ')} • '
          '${task.priority} • '
          'due ${DateFormat.MMMd().format(task.dueDate)}',
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context)
                .colorScheme
                .outline,
          ),
          const SizedBox(height: 12),
          Text(text),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.retry,
  });

  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load data',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirm(
  BuildContext context,
  String title,
  String body,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}