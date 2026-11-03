import 'package:flutter/material.dart';
import 'package:mochi_stok/core/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onViewAll});

  // Callback ini diteruskan ke tombol "Semua" agar navigasi ditentukan oleh parent.
  final VoidCallback? onViewAll;

  // Data contoh untuk menampilkan bahan yang jumlah stoknya perlu diperhatikan.
  static const _lowStockItems = [
    _LowStockItem(
      name: 'Mochi matcha',
      minimum: 'Minimum 30 pcs',
      current: '22 pcs',
      progress: 0.36,
    ),
    _LowStockItem(
      name: 'Gula pasir',
      minimum: 'Minimum 5 kg',
      current: '4 kg',
      progress: 0.40,
    ),
    _LowStockItem(
      name: 'Bubuk matcha',
      minimum: 'Minimum 1 kg',
      current: '0,8 kg',
      progress: 0.40,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // SafeArea mencegah konten tertutup status bar; ListView membuat halaman bisa digulir.
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text(
            _todayInIndonesian(),
            style: const TextStyle(
              color: MochiTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Halo, Admin',
            style: TextStyle(
              color: MochiTheme.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  count: '8',
                  title: 'Jenis item',
                  isHighlighted: false,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  count: '3',
                  title: 'Stok menipis',
                  isHighlighted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LowStockCard(items: _lowStockItems),
          const SizedBox(height: 12),
          _RecentActivityCard(onViewAll: onViewAll),
        ],
      ),
    );
  }

  String _todayInIndonesian() {
    // DateTime.weekday dimulai dari 1 (Senin), sehingga indeks daftar dikurangi 1.
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final today = DateTime.now();
    // Nama hari dan bulan diambil dari daftar bahasa Indonesia berdasarkan tanggal saat ini.
    return '${weekdays[today.weekday - 1]}, ${today.day} '
        '${months[today.month - 1]} ${today.year}';
  }
}

// Kartu ringkasan dipisahkan menjadi widget agar bisa digunakan ulang dengan isi berbeda.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.count,
    required this.title,
    required this.isHighlighted,
  });

  final String count;
  final String title;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        // Warna kartu berubah untuk menonjolkan informasi yang perlu diperhatikan.
        color: isHighlighted ? const Color(0xFFFFD8E0) : Colors.white,
        border: isHighlighted
            ? null
            : Border.all(color: const Color(0xFFFFA9BA)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              color: isHighlighted ? MochiTheme.primary : MochiTheme.ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              color: isHighlighted ? MochiTheme.primary : MochiTheme.ink,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// Kartu ini menampilkan daftar stok menipis berdasarkan data yang diterima.
class _LowStockCard extends StatelessWidget {
  const _LowStockCard({required this.items});

  final List<_LowStockItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFA9BA)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perlu diisi ulang',
            style: TextStyle(
              color: MochiTheme.ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Divider(color: Color(0xFFFFA9BA), height: 8),
          // Setiap data dibuat menjadi baris; pemisah tidak ditambahkan setelah baris terakhir.
          for (var index = 0; index < items.length; index++) ...[
            _LowStockRow(item: items[index]),
            if (index < items.length - 1)
              const Divider(color: Color(0xFFFFA9BA), height: 12),
          ],
        ],
      ),
    );
  }
}

// Model sederhana untuk menyimpan informasi yang dibutuhkan pada satu item stok.
class _LowStockItem {
  const _LowStockItem({
    required this.name,
    required this.minimum,
    required this.current,
    required this.progress,
  });

  final String name;
  final String minimum;
  final String current;
  final double progress;
}

// Widget baris menampilkan nama, batas minimum, jumlah saat ini, dan indikator stok.
class _LowStockRow extends StatelessWidget {
  const _LowStockRow({required this.item});

  final _LowStockItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: MochiTheme.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.minimum,
                      style: const TextStyle(
                        color: MochiTheme.primary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.current,
                    style: const TextStyle(
                      color: MochiTheme.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD8E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Menipis',
                      style: TextStyle(
                        color: MochiTheme.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              // Nilai progress menentukan panjang indikator, dengan rentang 0.0 sampai 1.0.
              value: item.progress,
              minHeight: 4,
              backgroundColor: const Color(0xFFFFA9BA),
              valueColor: const AlwaysStoppedAnimation(MochiTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// Bagian aktivitas menyediakan tombol yang aksinya diberikan oleh widget parent.
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({this.onViewAll});

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFA9BA)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Terakhir dicatat',
              style: TextStyle(
                color: MochiTheme.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              foregroundColor: MochiTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Semua',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
