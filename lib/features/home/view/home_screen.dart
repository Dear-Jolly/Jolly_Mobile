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
import '../../../domain/entity/letter_page.dart';
import '../../../domain/model/result.dart';
import '../../../domain/usecase/letter/get_home_data_usecase.dart';
import '../../../domain/usecase/letter/get_letters_usecase.dart';

enum SortOrder { recent, oldest }

extension on SortOrder {
  String get label => switch (this) {
    SortOrder.recent => '최신순',
    SortOrder.oldest => '오래된순',
  };

  LetterSortOrder get requestSort => switch (this) {
    SortOrder.recent => LetterSortOrder.latest,
    SortOrder.oldest => LetterSortOrder.oldest,
  };
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _pageSize = 50;

  final _scrollController = ScrollController();

  SortOrder _sortOrder = SortOrder.recent;
  HomeData? _homeData;
  List<Letter> _letters = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasNext = false;
  int _currentPage = 0;
  String? _errorMessage;

  int get _stampCount => _homeData?.totalStampCount ?? 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadHome();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              _loadHome();
            },
            child: Row(
              children: [
                Text(
                  _sortOrder.label,
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
    final itemCount = _letters.length + (_isLoadingMore ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      itemCount: itemCount,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= _letters.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final letter = _letters[index];
        return LetterCard(
          letter: letter,
          onTap: letter.hasFeedback
              ? () => context.push('/review/${letter.id}')
              : () => JollyToast.show(
                  context,
                  message: 'Jolly가 아직 편지를 검토하고 있어요.',
                ),
        );
      },
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      _loadMoreLetters();
    }
  }

  Future<void> _loadHome() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _errorMessage = null;
      });
    }

    final homeResult = await locator<GetHomeDataUseCase>().execute();
    final lettersResult = await locator<GetLettersUseCase>().execute(
      page: 0,
      size: _pageSize,
      sort: _sortOrder.requestSort,
    );

    if (!mounted) return;

    if (homeResult is Success<HomeData> &&
        lettersResult is Success<LetterPage>) {
      setState(() {
        _homeData = homeResult.data;
        _letters = lettersResult.data.letters;
        _hasNext = lettersResult.data.hasNext;
        _currentPage = 0;
        _isLoading = false;
        _isLoadingMore = false;
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
      _isLoadingMore = false;
      _errorMessage = message;
    });
    JollyToast.show(context, message: message);
  }

  Future<void> _loadMoreLetters() async {
    if (_isLoading || _isLoadingMore || !_hasNext) {
      return;
    }

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final result = await locator<GetLettersUseCase>().execute(
      page: nextPage,
      size: _pageSize,
      sort: _sortOrder.requestSort,
    );

    if (!mounted) return;

    switch (result) {
      case Success(data: final page):
        setState(() {
          _letters = [..._letters, ...page.letters];
          _hasNext = page.hasNext;
          _currentPage = nextPage;
          _isLoadingMore = false;
        });
      case Failure(message: final message):
        setState(() => _isLoadingMore = false);
        JollyToast.show(context, message: message);
    }
  }

  String? _failureMessage<T>(Result<T> result) {
    return switch (result) {
      Failure(message: final message) => message,
      _ => null,
    };
  }
}
