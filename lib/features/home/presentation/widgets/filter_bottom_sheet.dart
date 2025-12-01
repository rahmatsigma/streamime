import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  // Kita terima filter yang sedang aktif biar tombolnya nyala
  final String currentType;
  final String currentStatus;
  final Function(String type, String status) onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentType,
    required this.currentStatus,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedType;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentType;
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter Pencarian",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Reset Filter
                  setState(() {
                    _selectedType = 'All';
                    _selectedStatus = 'All';
                  });
                },
                child: const Text("Reset"),
              ),
            ],
          ),
          const Divider(),

          // 1. Filter Tipe
          const SizedBox(height: 10),
          const Text(
            "Tipe Komik",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['All', 'Manga', 'Manhwa', 'Manhua'].map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                selectedColor: Colors.blueAccent,
                labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedType = type);
                },
              );
            }).toList(),
          ),

          // 2. Filter Status
          const SizedBox(height: 16),
          const Text("Status", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['All', 'Ongoing', 'Completed'].map((status) {
              final isSelected = _selectedStatus == status;
              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                selectedColor: Colors.green,
                labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedStatus = status);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Tombol Terapkan
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedType, _selectedStatus);
                Navigator.pop(context); // Tutup sheet
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Terapkan Filter",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
