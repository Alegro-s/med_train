import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/course_service.dart';
import '../../services/module_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/auth_service.dart';
import '../../models/course_model.dart';
import '../../models/module_model.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/constants/colors.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late final CourseService _courseService;
  late final ModuleService _moduleService;
  late final EnrollmentService _enrollmentService;
  bool _isEnrolled = false;
  int _progressPercent = 0;
  int _totalStudents = 2847; 
  List<CourseModule> _modules = []; 

  @override
  void initState() {
    super.initState();
    _courseService = context.read<CourseService>();
    _moduleService = context.read<ModuleService>();
    _enrollmentService = context.read<EnrollmentService>();
    _checkEnrollment();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final modules = await _moduleService.getModulesForCourse(widget.courseId);
    if (mounted) {
      setState(() {
        _modules = modules;
      });
    }
  }

  Future<void> _checkEnrollment() async {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) return;
    
    final enrolled = await _enrollmentService.isEnrolled(userId, widget.courseId);
    final enrollment = await _enrollmentService.getEnrollment(userId, widget.courseId);
    
    if (mounted) {
      setState(() {
        _isEnrolled = enrolled;
        _progressPercent = enrollment?.progressPercent ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Course?>(
        future: _courseService.getCourseById(widget.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Курс не найден'));
          }
          final course = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.favorite,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.description ?? 'Повышение квалификации для врачей',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(Icons.menu_book, '${_modules.length} Модулей'),
                          _buildStatItem(Icons.access_time, '${course.durationHours} Часов'),
                          _buildStatItem(Icons.card_membership, 'Сертификат'),
                          _buildStatItem(Icons.people, '$_totalStudents Обучающихся'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Описание курса',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Курс предназначен для врачей, которые хотят обновить и систематизировать знания в области диагностики и лечения сердечно-сосудистых заболеваний. Вы изучите современные методы обследования, протоколы лечения и подходы к реабилитации пациентов.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Модули курса',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _modules.length) return null;
                      
                      final module = _modules[index];
                      final isLocked = !_isEnrolled;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isLocked ? AppColors.textSecondary : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            module.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Описание модуля ${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (_isEnrolled && index == 0) ...[
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: 0.3, // Для демо
                                  backgroundColor: Colors.grey[300],
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '30% пройдено',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                          trailing: isLocked
                              ? const Icon(Icons.lock, color: AppColors.textSecondary)
                              : const Icon(Icons.lock_open, color: AppColors.primary),
                          onTap: _isEnrolled 
                              ? () => context.push('/module/${module.id}')
                              : null,
                        ),
                      );
                    },
                    childCount: _modules.length,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    const Text(
                      'Чему вы научитесь',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLearningPoint(
                      Icons.check_circle,
                      'Современные методы диагностики сердечно-сосудистых заболеваний',
                    ),
                    _buildLearningPoint(
                      Icons.check_circle,
                      'Медикаментозную поддержку в период восстановления',
                    ),
                    _buildLearningPoint(
                      Icons.check_circle,
                      'Правила мониторинга эффективности реабилитационных мероприятий',
                    ),
                    _buildLearningPoint(
                      Icons.check_circle,
                      'Интерпретацию результатов ЭКГ и ЭхоКГ',
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Цена',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${course.price.toStringAsFixed(0)} ₽',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _isEnrolled
                              ? ElevatedButton(
                                  onPressed: _modules.isNotEmpty
                                      ? () => context.push('/module/${_modules.first.id}')
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                  ),
                                  child: const Text('Продолжить обучение'),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    final userId = context.read<AuthService>().currentUser?.id;
                                    if (userId == null) return;
                                    
                                    await _enrollmentService.enroll(userId, widget.courseId);
                                    if (mounted) {
                                      setState(() => _isEnrolled = true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Вы записаны на курс!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Записаться на курс'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLearningPoint(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}