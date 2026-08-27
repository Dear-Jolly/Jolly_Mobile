import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/check_pattern.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../../../core/widgets/letter_card.dart';
import '../../../domain/entity/home_data.dart';
import '../../../domain/entity/letter.dart';
import '../../../domain/model/result.dart';
import '../../../domain/usecase/letter/get_home_data_usecase.dart';
import '../../../domain/usecase/letter/get_letters_usecase.dart';

enum SortOrder { recent, oldest }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SortOrder _sortOrder = SortOrder.recent;
  HomeData? _homeData;
  List<Letter> _letters = [];
  bool _isLoading = true;
  String? _errorMessage;

  int get _stampCount => _homeData?.totalStampCount ?? 0;

  List<Letter> get _sortedLetters {
    final letters = [..._letters];
    letters.sort((a, b) {
      final result = b.date.compareTo(a.date);
      return _sortOrder == SortOrder.recent ? result : -result;
    });
    return letters;
  }

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory100,
      body: Stack(
        children: [
          const CheckPattern(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildSortBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: GestureDetector(
          onTap: () async {
            await context.push('/write');
            if (mounted) {
              _loadHome();
            }
          },
          child: SvgPicture.asset(
            'assets/icons/ic_write.svg',
            width: 63,
            height: 63,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final nickname = _homeData?.nickname.isNotEmpty == true
        ? _homeData!.nickname
        : 'Jolly';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: nickname,
                        style: AppTextTheme.head3B20.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      TextSpan(
                        text: '님, 지금까지',
                        style: AppTextTheme.head5Md20.copyWith(
                          color: AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '총 $_stampCount개',
                            style: AppTextTheme.head3B20.copyWith(
                              color: AppColors.burgundy,
                            ),
                          ),
                          TextSpan(
                            text: '의 우표를 모았어요!',
                            style: AppTextTheme.head5Md20.copyWith(
                              color: AppColors.gray900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/images/img_mini_letter.png',
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: SvgPicture.asset(
              'assets/icons/ic_setting.svg',
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Row(
        children: [
          const Spacer(),
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
                  width: 18,
                  height: 18,
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextTheme.body6Md15.copyWith(color: AppColors.gray600),
            ),
            const SizedBox(height: 16),
            JollyOutlinedButton(text: '다시 시도', onPressed: _loadHome),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHome,
      child: _letters.isEmpty ? _buildEmptyState() : _buildLetterList(),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/img_mini_letter.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(width: 40, height: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  '아직 작성한 편지가 없어요.\n편지를 작성해보세요!',
                  textAlign: TextAlign.center,
                  style: AppTextTheme.body6Md15.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLetterList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      itemCount: _sortedLetters.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final letter = _sortedLetters[index];
        return LetterCard(
          letter: letter,
          onTap: () => context.push('/review/${letter.id}'),
        );
      },
    );
  }

  Future<void> _loadHome() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final homeResult = await locator<GetHomeDataUseCase>().execute();
    final lettersResult = await locator<GetLettersUseCase>().execute();

    if (!mounted) return;

    if (homeResult is Success<HomeData> &&
        lettersResult is Success<List<Letter>>) {
      setState(() {
        _homeData = homeResult.data;
        _letters = lettersResult.data;
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    final message =
        _failureMessage(homeResult) ??
        _failureMessage(lettersResult) ??
        '편지를 불러오지 못했습니다.';

    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
    JollyToast.show(context, message: message);
  }

  String? _failureMessage<T>(Result<T> result) {
    return switch (result) {
      Failure(message: final message) => message,
      _ => null,
    };
  }
}
