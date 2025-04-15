import 'package:flutter/material.dart';

class PermissionTable extends StatefulWidget {
  @override
  _PermissionTableState createState() => _PermissionTableState();
}

class _PermissionTableState extends State<PermissionTable> {
  // State to manage checkbox values and disabled status
  final Map<String, Map<String, bool>> _checkboxValues = {
    'Job': {
      'create': false,
      'update': false,
      'delete': false,
      'read': false,
    },
    'Job Application': {
      'create': false,
      'update': false,
      'delete': false,
      'read': false,
    },
  };

  // State to manage disabled status
  final Map<String, Map<String, bool>> _checkboxDisabled = {
    'Job': {
      'create': false,
      'update': false,
      'delete': false,
      'read': true,
    },
    'Job Application': {
      'create': false,
      'update': false,
      'delete': false,
      'read': false,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 10),
        child: Table(
          border: TableBorder.all(
            borderRadius: BorderRadius.circular(10),
            style: BorderStyle.none,
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(2), // Adjust width as needed
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
            4: FlexColumnWidth(),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(),
              children: [
                TableCell(child: SizedBox()), // Empty top-left cell
                TableCell(child: Center(child: Text('Create'))),
                TableCell(child: Center(child: Text('Update'))),
                TableCell(child: Center(child: Text('Delete'))),
                TableCell(child: Center(child: Text('Read'))),
              ],
            ),
            ..._checkboxValues.entries.map((entry) {
              final itemName = entry.key;
              final itemValues = entry.value;
              final itemDisabled = _checkboxDisabled[itemName]!;

              return TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(itemName),
                    ),
                  ),
                  ...itemValues.entries.map((valueEntry) {
                    final action = valueEntry.key;
                    final value = valueEntry.value;
                    final disabled = itemDisabled[action]!;

                    return TableCell(
                      child: Center(
                        child: Checkbox(
                          splashRadius: 50,
                          value: value,
                          onChanged: disabled
                              ? null
                              : (newValue) {
                                  setState(() {
                                    _checkboxValues[itemName]![action] =
                                        newValue!;
                                  });
                                },
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
