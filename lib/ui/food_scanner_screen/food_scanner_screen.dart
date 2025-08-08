import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screen.dart';

class FoodScannerScreen extends StatelessWidget {
  const FoodScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scanner = Provider.of<FoodScannerManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Máy quét thực phẩm"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Để nội dung gọn lại
            children: [
              if (scanner.isLoading) const CircularProgressIndicator(),
              if (scanner.error != null)
                Text(scanner.error!, style: const TextStyle(color: Colors.red)),
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
              ElevatedButton.icon(
                onPressed: () => scanner.scanFood(context),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Quét thực phẩm"),
              ),
              if (scanner.foodItem != null || scanner.error != null)
                TextButton(
                  onPressed: () => scanner.reset(),
                  child: const Text("Quét lại"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
