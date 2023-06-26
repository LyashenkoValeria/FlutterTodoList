import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCategoryDialog extends StatefulWidget {
  final String userID;

  const AddCategoryDialog({Key? key, required this.userID}) : super(key: key);

  @override
  State<AddCategoryDialog> createState() =>
      _AddCategoryDialogState(userID: userID);
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final String userID;

  _AddCategoryDialogState({required this.userID});

  String categoryTitle = '';
  final TextEditingController iconController = TextEditingController();
  IconLabel selectedIcon = IconLabel.meet;

  final ButtonStyle roundButtonStyle = ElevatedButton.styleFrom(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dbCategories = FirebaseFirestore.instance
        .collection('userCategories')
        .doc(userID)
        .collection('categories');

    final List<DropdownMenuEntry<IconLabel>> iconEntries =
        <DropdownMenuEntry<IconLabel>>[];
    for (final IconLabel icon in IconLabel.values) {
      iconEntries.add(
        DropdownMenuEntry<IconLabel>(value: icon, label: icon.label),
      );
    }

    return ElevatedButton(
      onPressed: () {
        categoryTitle = '';
        selectedIcon = IconLabel.meet;
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Новая категория'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Название',
                              border: OutlineInputBorder()),
                          onChanged: (String category) {
                            categoryTitle = category;
                          },
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 20)),
                        Row(
                          children: [
                            DropdownMenu<IconLabel>(
                              initialSelection: IconLabel.meet,
                              controller: iconController,
                              label: const Text('Иконка'),
                              dropdownMenuEntries: iconEntries,
                              onSelected: (IconLabel? icon) {
                                setState(() {
                                  selectedIcon = icon!;
                                });
                              },
                            ),
                            const Padding(padding: EdgeInsets.only(left: 20)),
                            Icon(
                              selectedIcon.icon,
                              color: const Color(0xFF082427),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: roundButtonStyle,
                        child: const Text('Отменить'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (categoryTitle.isNotEmpty) {
                            dbCategories.add({
                              'categoryTitle': categoryTitle,
                              'icon': selectedIcon.label,
                              'all': 0,
                              'ready': 0
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        style: roundButtonStyle,
                        child: const Text('Добавить'),
                      ),
                    ],
                  );
                },
              );
            });
      },
      style: roundButtonStyle,
      child: const Icon(
        Icons.add,
      ),
    );
  }
}

enum IconLabel {
  meet('Встречи', Icons.family_restroom),
  home('Дом', Icons.home),
  game('Игры', Icons.videogame_asset_rounded),
  film('Кино', Icons.tv),
  book('Книги', Icons.book),
  music('Музыка', Icons.music_note),
  buy('Покупки', Icons.shopping_basket),
  holidays('Праздники', Icons.beach_access),
  travel('Путешествия', Icons.airplanemode_active),
  work('Работа', Icons.work),
  sport('Спорт', Icons.directions_run),
  clean('Уборка', Icons.cleaning_services),
  hobby('Хобби', Icons.brush);

  const IconLabel(this.label, this.icon);

  final String label;
  final IconData icon;
}
