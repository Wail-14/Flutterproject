import 'package:flutter/material.dart';


class AddPlaceForm extends StatefulWidget {
  final Function(String) onSubmit;

  const AddPlaceForm({super.key, required this.onSubmit});

  @override
  State<AddPlaceForm> createState() => _AddPlaceFormState();
}

class _AddPlaceFormState extends State<AddPlaceForm> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nom du lieu",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () {
            widget.onSubmit(controller.text);
            Navigator.pop(context);
          },
          child: const Text("Ajouter"),
        ),
      ],
    );
  }
}
