import '../../../domain/entity/home_data.dart';
import 'letter_dto.dart';

class HomeDto {
  final int stampCount;
  final List<LetterDto> letters;

  const HomeDto({
    required this.stampCount,
    required this.letters,
  });

  factory HomeDto.fromJson(Map<String, dynamic> json) {
    return HomeDto(
      stampCount: json['stampCount'] as int? ?? 0,
      letters: (json['letters'] as List<dynamic>?)
              ?.map((e) => LetterDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  HomeData toEntity() {
    return HomeData(
      stampCount: stampCount,
      letters: letters.map((e) => e.toEntity()).toList(),
    );
  }
}
