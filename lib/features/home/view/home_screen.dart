import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/widgets/check_pattern.dart';
import '../../../core/widgets/feedback_delivery_failure_dialog.dart';
import '../../../core/widgets/jolly_button.dart';
import '../../../core/widgets/jolly_loading_indicator.dart';
import '../../../core/widgets/jolly_toast.dart';
import '../../../core/widgets/letter_card.dart';
import '../../../domain/entity/home_data.dart';
import '../../../domain/entity/letter.dart';
import '../../../domain/entity/letter_page.dart';
import '../../../domain/model/result.dart';

enum SortOrder { recent, oldest }

extension on SortOrder {
  String get label => switch (this) {
    SortOrder.recent => '최신순',
    SortOrder.oldest => '오래된 순',
  };

  String get directionIconAsset => switch (this) {
    SortOrder.recent => 'assets/icons/ic_direction_down.svg',
    SortOrder.oldest => 'assets/icons/ic_direction_up.svg',
  };

  LetterSortOrder get requestSort => switch (this) {
    SortOrder.recent => LetterSortOrder.latest,
    SortOrder.oldest => LetterSortOrder.oldest,
  };
}

class HomeScreen extends ConsumerStatefulWidget {
  final int? initialPendingLetterId;
  final DateTime? initialPendingStartedAt;

  const HomeScreen({
    super.key,
    this.initialPendingLetterId,
    this.initialPendingStartedAt,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  static const _pageSize = 50;
  static const _feedbackPollingInterval = Duration(seconds: 10);
  static const _countdownTickInterval = Duration(seconds: 1);
  static const _rateLimitBackoff = Duration(minutes: 1);

  final _scrollController = ScrollController();
  final Map<int, DateTime> _pendingStartedAtOverrides = {};
  final Set<int> _feedbackFailedLetterIds = {};
  Timer? _feedbackPollingTimer;
  Timer? _countdownTimer;
  Timer? _rateLimitResumeTimer;

  SortOrder _sortOrder = SortOrder.recent;
  HomeData? _homeData;
  List<Letter> _letters = [];
  DateTime _now = DateTime.now();
  DateTime? _rateLimitPausedUntil;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isRefreshingInBackground = false;
  bool _isAppActive = true;
  bool _hasNext = false;
  int _currentPage = 0;
  int? _checkingLetterId;
  String? _errorMessage;

  int get _stampCount => _homeData?.totalStampCount ?? 0;
  bool get _hasLettersWaitingForFeedback =>
      _letters.any((letter) => !letter.hasFeedback);
  bool get _hasActiveCountdownBadges => _letters.any(_isCountdownActive);

  @override
  void initState() {
    super.initState();
    _saveInitialPendingStartedAt();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _loadHome();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopFeedbackPolling();
    _stopCountdownTimer();
    _rateLimitResumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppActive = true;
      setState(() => _now = DateTime.now());
      _syncPendingLetterTimers();
      unawaited(_refreshHomeSilently());
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _isAppActive = false;
      _stopFeedbackPolling();
      _stopCountdownTimer();
    }
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
            onTap: () async {
              await context.push('/settings');
              if (mounted) {
                _loadHome();
              }
            },
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
                  style: AppTextTheme.body9Md14.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                SvgPicture.asset(
                  _sortOrder.directionIconAsset,
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
      return const Center(child: JollyLoadingIndicator());
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
            child: Center(child: JollyLoadingIndicator(width: 36, height: 51)),
          );
        }

        final letter = _letters[index];
        final displayLetter = _displayLetterFor(letter);
        return LetterCard(
          letter: displayLetter,
          now: _now,
          countdownStartedAt: _activeCountdownStartedAtFor(letter),
          onTap: () => _handleLetterTap(letter),
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

    final homeResult = await ref.read(getHomeDataUseCaseProvider).execute();
    final lettersResult = await ref
        .read(getLettersUseCaseProvider)
        .execute(page: 0, size: _pageSize, sort: _sortOrder.requestSort);

    if (!mounted) return;

    if (homeResult is Success<HomeData> &&
        lettersResult is Success<LetterPage>) {
      _recordFailedLetters(lettersResult.data.letters);
      setState(() {
        _homeData = homeResult.data;
        _letters = lettersResult.data.letters;
        _now = DateTime.now();
        _hasNext = lettersResult.data.hasNext;
        _currentPage = 0;
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = null;
      });
      _syncPendingLetterTimers();
      return;
    }

    final message =
        _failureMessage(homeResult) ??
        _failureMessage(lettersResult) ??
        '편지를 불러오지 못했습니다.';

    setState(() {
      _isLoading = false;
      _isLoadingMore = false;
      _now = DateTime.now();
      _errorMessage = message;
    });
    _syncPendingLetterTimers();
    JollyToast.show(context, message: message);
  }

  Future<void> _loadMoreLetters() async {
    if (_isLoading || _isLoadingMore || !_hasNext) {
      return;
    }

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final result = await ref
        .read(getLettersUseCaseProvider)
        .execute(page: nextPage, size: _pageSize, sort: _sortOrder.requestSort);

    if (!mounted) return;

    switch (result) {
      case Success(data: final page):
        _recordFailedLetters(page.letters);
        setState(() {
          _letters = [..._letters, ...page.letters];
          _hasNext = page.hasNext;
          _currentPage = nextPage;
          _isLoadingMore = false;
        });
        _syncPendingLetterTimers();
      case Failure(message: final message):
        setState(() => _isLoadingMore = false);
        JollyToast.show(context, message: message);
    }
  }

  Future<void> _refreshHomeSilently() async {
    if (!mounted || _isLoading || _isLoadingMore || _isRefreshingInBackground) {
      return;
    }

    _isRefreshingInBackground = true;
    try {
      final pageCount = _currentPage + 1;
      final homeResult = await ref.read(getHomeDataUseCaseProvider).execute();
      final lettersResults = await Future.wait<Result<LetterPage>>(
        List.generate(
          pageCount,
          (page) => ref
              .read(getLettersUseCaseProvider)
              .execute(
                page: page,
                size: _pageSize,
                sort: _sortOrder.requestSort,
              ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (homeResult is! Success<HomeData>) {
        _pauseFeedbackPollingIfRateLimited(homeResult);
        return;
      }

      final refreshedLetters = <Letter>[];
      var hasNext = _hasNext;

      for (var index = 0; index < lettersResults.length; index++) {
        final result = lettersResults[index];
        switch (result) {
          case Success(data: final page):
            _recordFailedLetters(page.letters);
            refreshedLetters.addAll(page.letters);
            if (index == lettersResults.length - 1) {
              hasNext = page.hasNext;
            }
          case Failure():
            _pauseFeedbackPollingIfRateLimited(result);
            return;
        }
      }

      setState(() {
        _homeData = homeResult.data;
        _letters = refreshedLetters;
        _now = DateTime.now();
        _hasNext = hasNext;
        _errorMessage = null;
      });
    } finally {
      _isRefreshingInBackground = false;
      if (mounted) {
        _syncPendingLetterTimers();
      }
    }
  }

  Future<void> _handleLetterTap(Letter letter) async {
    _now = DateTime.now();

    if (_isCountdownActive(letter)) {
      JollyToast.show(context, message: 'Jolly가 아직 편지를 검토하고 있어요.');
      return;
    }

    if (letter.hasFeedback) {
      await context.push('/review/${letter.id}');
      if (mounted) {
        unawaited(_refreshHomeSilently());
      }
      return;
    }

    if (_checkingLetterId == letter.id) {
      return;
    }

    setState(() => _checkingLetterId = letter.id);
    final result = await ref
        .read(getLetterDetailUseCaseProvider)
        .execute(letter.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _checkingLetterId = null;
      _now = DateTime.now();
    });

    switch (result) {
      case Success(data: final latestLetter):
        _recordFailedLetters([latestLetter]);
        _replaceLetter(latestLetter);
        _syncPendingLetterTimers();
        if (latestLetter.isFeedbackFailed) {
          await FeedbackDeliveryFailureDialog.show(context);
        } else if (!_isCountdownActive(latestLetter) &&
            latestLetter.hasFeedback) {
          await context.push('/review/${latestLetter.id}');
          if (mounted) {
            unawaited(_refreshHomeSilently());
          }
        } else if (_isFeedbackWaitExpired(latestLetter)) {
          await FeedbackDeliveryFailureDialog.show(context);
        } else {
          JollyToast.show(context, message: 'Jolly가 아직 편지를 검토하고 있어요.');
        }
      case Failure(message: final message):
        JollyToast.show(context, message: message);
    }
  }

  void _replaceLetter(Letter updatedLetter) {
    final index = _letters.indexWhere(
      (letter) => letter.id == updatedLetter.id,
    );
    if (index == -1) {
      return;
    }

    final updatedLetters = List<Letter>.of(_letters);
    updatedLetters[index] = updatedLetter;
    setState(() => _letters = updatedLetters);
  }

  void _recordFailedLetters(Iterable<Letter> letters) {
    for (final letter in letters) {
      if (letter.isFeedbackFailed) {
        _feedbackFailedLetterIds.add(letter.id);
      }
    }
  }

  void _saveInitialPendingStartedAt() {
    final id = widget.initialPendingLetterId;
    final startedAt = widget.initialPendingStartedAt;
    if (id != null && startedAt != null) {
      _pendingStartedAtOverrides[id] = startedAt;
    }
  }

  DateTime? _pendingStartedAtFor(Letter letter) {
    return letter.createdAt ?? _pendingStartedAtOverrides[letter.id];
  }

  DateTime? _activeCountdownStartedAtFor(Letter letter) {
    if (!_isCountdownActive(letter)) {
      return null;
    }
    return _pendingStartedAtFor(letter);
  }

  bool _isCountdownActive(Letter letter) {
    if (letter.isFeedbackFailed ||
        _feedbackFailedLetterIds.contains(letter.id)) {
      return false;
    }

    final startedAt = _pendingStartedAtFor(letter);
    if (startedAt == null) {
      return false;
    }

    return _now.difference(startedAt) < LetterCard.feedbackWaitDuration;
  }

  bool _isFeedbackWaitExpired(Letter letter) {
    final startedAt = _pendingStartedAtFor(letter);
    if (startedAt == null) {
      return false;
    }

    return _now.difference(startedAt) >= LetterCard.feedbackWaitDuration;
  }

  Letter _displayLetterFor(Letter letter) {
    if (letter.isFeedbackFailed ||
        _feedbackFailedLetterIds.contains(letter.id) ||
        !_isCountdownActive(letter)) {
      return letter;
    }

    return letter.copyWith(
      status: LetterStatus.feedbackInProgress,
      stampImage: null,
      isNew: false,
    );
  }

  void _syncPendingLetterTimers() {
    _syncFeedbackPolling();
    _syncCountdownTimer();
  }

  void _syncCountdownTimer() {
    if (!_isAppActive || !_hasActiveCountdownBadges) {
      _stopCountdownTimer();
      return;
    }

    if (_countdownTimer != null) {
      return;
    }

    _countdownTimer = Timer.periodic(_countdownTickInterval, (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }

      if (!_isAppActive || !_hasActiveCountdownBadges) {
        _stopCountdownTimer();
        return;
      }
    });
  }

  void _stopCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _syncFeedbackPolling() {
    if (_isRateLimitPauseActive()) {
      _stopFeedbackPolling();
      _scheduleRateLimitResume();
      return;
    }

    if (!_isAppActive || !_hasLettersWaitingForFeedback) {
      _stopFeedbackPolling();
      return;
    }

    if (_feedbackPollingTimer != null) {
      return;
    }

    _feedbackPollingTimer = Timer.periodic(
      _feedbackPollingInterval,
      (_) => unawaited(_refreshHomeSilently()),
    );
  }

  void _stopFeedbackPolling() {
    _feedbackPollingTimer?.cancel();
    _feedbackPollingTimer = null;
  }

  bool _isRateLimitPauseActive() {
    final pausedUntil = _rateLimitPausedUntil;
    if (pausedUntil == null) {
      return false;
    }

    if (DateTime.now().isBefore(pausedUntil)) {
      return true;
    }

    _rateLimitPausedUntil = null;
    return false;
  }

  void _pauseFeedbackPollingIfRateLimited<T>(Result<T> result) {
    if (result is Failure<T> && result.isRateLimited) {
      _rateLimitPausedUntil = DateTime.now().add(_rateLimitBackoff);
      _stopFeedbackPolling();
      _scheduleRateLimitResume();
    }
  }

  void _scheduleRateLimitResume() {
    final pausedUntil = _rateLimitPausedUntil;
    if (pausedUntil == null) {
      return;
    }

    _rateLimitResumeTimer?.cancel();
    final delay = pausedUntil.difference(DateTime.now());
    _rateLimitResumeTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      if (!mounted) {
        return;
      }
      _rateLimitPausedUntil = null;
      _syncPendingLetterTimers();
    });
  }

  String? _failureMessage<T>(Result<T> result) {
    return switch (result) {
      Failure(message: final message) => message,
      _ => null,
    };
  }
}
