import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/letter_card.dart';
import '../../../domain/entity/letter.dart';

enum SortOrder { recent, oldest }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SortOrder _sortOrder = SortOrder.recent;

  // TODO: Replace with real data from repository
  final List<Letter> _letters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),
            // Sort & stamp count
            _buildSortBar(),
            // Letter list
            Expanded(
              child: _letters.isEmpty ? _buildEmptyState() : _buildLetterList(),
            ),
          ],
        ),
      ),
      // Write FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/write'),
        backgroundColor: AppColors.burgundy,
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          'assets/icons/ic_write.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Text(
            'Dear Jolly',
            style: AppTextTheme.head3B20.copyWith(color: AppColors.gray900),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: SvgPicture.asset(
              'assets/icons/ic_setting.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.gray900,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          // Stamp count
          Row(
            children: [
              Image.asset(
                'assets/images/stamp_flower.png',
                width: 20,
                height: 26,
                errorBuilder: (_, __, ___) => const SizedBox(width: 20),
              ),
              const SizedBox(width: 4),
              Text(
                '0',
                style: AppTextTheme.detail6Md12.copyWith(color: AppColors.gray600),
              ),
            ],
          ),
          const Spacer(),
          // Sort dropdown
          GestureDetector(
            onTap: () {
              setState(() {
                _sortOrder = _sortOrder == SortOrder.recent
                    ? SortOrder.oldest
                    : SortOrder.recent;
              });
            },
            child: Row(
              children: [
                Text(
                  _sortOrder == SortOrder.recent ? '최신순' : '오래된순',
                  style: AppTextTheme.detail6Md12.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/ic_direction_down.svg',
                  width: 12,
                  height: 12,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray600,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/img_mini_letter.png',
            width: 40,
            height: 40,
            errorBuilder: (_, __, ___) => const SizedBox(width: 40, height: 40),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 작성한 편지가 없어요.\n편지를 작성해보세요!',
            textAlign: TextAlign.center,
            style: AppTextTheme.body6Md15.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _letters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final letter = _letters[index];
        return LetterCard(
          letter: letter,
          onTap: () => context.push('/review'),
        );
      },
    );
  }
}
