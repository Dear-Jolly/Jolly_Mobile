import '../../../domain/entity/home_data.dart';

class HomeDto {
  final String nickname;
  final int totalStampCount;

  const HomeDto({required this.nickname, required this.totalStampCount});

  factory HomeDto.fromJson(Map<String, dynamic> json) {
    return HomeDto(
      nickname: json['nickname'] as String? ?? '',
      totalStampCount: json['totalStampCount'] as int? ?? 0,
    );
  }

  HomeData toEntity() {
    return HomeData(nickname: nickname, totalStampCount: totalStampCount);
  }
}
