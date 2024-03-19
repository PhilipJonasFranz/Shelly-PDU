import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

typedef SelectionMadeCallback = void Function(String value);

class DropdownSelection extends StatefulWidget {
  final String? placeholderText;
  final String? initialValue;
  final List<String> elements;
  final SelectionMadeCallback callback;

  const DropdownSelection(
      {super.key,
      required this.callback,
      this.placeholderText,
      this.initialValue,
      required this.elements});

  @override
  DropdownSelectionState createState() => DropdownSelectionState();
}

class DropdownSelectionState extends State<DropdownSelection> {
  String? _selectedValue;

  @override
  void initState() {
    if (widget.initialValue != null) {
      _selectedValue = widget.initialValue;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
        value: _selectedValue,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            )),
        hint: Text(
          widget.placeholderText ?? 'Select...',
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
