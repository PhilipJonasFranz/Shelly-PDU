import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

typedef ElementSelectedCallback = void Function(String element);

class DropdownBox extends StatefulWidget {
  final String? placeholderText;
  final String? initialValue;
  final List<String> elements;
  final ElementSelectedCallback callback;

  const DropdownBox(
      {super.key,
      required this.callback,
      this.placeholderText,
      this.initialValue,
      required this.elements});

  @override
  DropdownBoxState createState() => DropdownBoxState();
}

class DropdownBoxState extends State<DropdownBox> {
  String? _selectedValue;

  @override
  void initState() {
    if (widget.initialValue != null) {
      _selectedValue = widget.initialValue;
      widget.callback(_selectedValue!);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
        value: _selectedValue,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            )),
        hint: Text(
          widget.placeholderText ?? 'Selection',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        items: widget.elements
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ))
            .toList(),
        onChanged: (value) {
          _selectedValue = value;
          if (value != null) {
            widget.callback(value);
          }
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.only(right: 8),
        ),
        iconStyleData: IconStyleData(
            icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.onSurface,
        )),
        dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        )),
        menuItemStyleData: const MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
        ));
  }
}
