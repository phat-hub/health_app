import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screen.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<FoodScannerManager>(context, listen: false).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanner = Provider.of<FoodScannerManager>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scanner.error != null) {
        scanner.clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Máy quét thực phẩm")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (scanner.isLoading) const CircularProgressIndicator(),
              if (scanner.image != null)
                Image.file(scanner.image!, height: 200),
              const SizedBox(height: 16),
              if (scanner.foodItem != null)
                Card(
                  child: ListTile(
                    title: Text(scanner.foodItem!.name),
                    subtitle: Text(
                        "Calo: ${scanner.foodItem!.calories.toStringAsFixed(0)} kcal"),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => scanner.scanFoodFromCamera(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Chụp ảnh"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => scanner.scanFoodFromGallery(context),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Chọn ảnh"),
                  ),
                ],
              ),
              if (scanner.foodItem != null)
                TextButton(
                  onPressed: () => scanner.reset(),
                  child: const Text("Quay lại"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
