/// Model Kategori Bahan Baku yang dipetakan langsung ke tabel `categories` di database MySQL.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.description = '',
  });

  final int id;
  final String name;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'id_kategori': id,
      'nama_kategori': name,
      'keterangan': description,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.parse((json['id_kategori'] ?? json['id']).toString()),
      name: (json['nama_kategori'] ?? json['name'] ?? '').toString(),
      description: (json['keterangan'] ?? json['description'] ?? '').toString(),
    );
  }

  Category copyWith({
    String? name,
    String? description,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
