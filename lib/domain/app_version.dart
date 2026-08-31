/// Una versión `mayor.menor.parche`.
///
/// Comparar versiones como texto es la forma clásica de que "1.10.0" parezca
/// anterior a "1.9.0" y el actualizador ofrezca volver atrás. Por eso se
/// comparan como números.
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  /// Acepta lo que suele traer una etiqueta de release: `v1.2.3`, `1.2.3`,
  /// `1.2.3+7` (el `+build` de pubspec se ignora), `1.2` o `1`.
  ///
  /// Devuelve null si no hay ni un número reconocible, en vez de lanzar: una
  /// etiqueta rara en GitHub no debe tirar la app.
  static AppVersion? tryParse(String? raw) {
    if (raw == null) return null;

    final match = RegExp(
      r'(\d+)(?:\.(\d+))?(?:\.(\d+))?',
    ).firstMatch(raw.trim());
    if (match == null) return null;

    return AppVersion(
      int.parse(match.group(1)!),
      int.tryParse(match.group(2) ?? '') ?? 0,
      int.tryParse(match.group(3) ?? '') ?? 0,
    );
  }

  @override
  int compareTo(AppVersion other) {
    final byMajor = major.compareTo(other.major);
    if (byMajor != 0) return byMajor;
    final byMinor = minor.compareTo(other.minor);
    if (byMinor != 0) return byMinor;
    return patch.compareTo(other.patch);
  }

  bool isNewerThan(AppVersion other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion &&
      other.major == major &&
      other.minor == minor &&
      other.patch == patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
