import 'dart:async';

import 'package:flutter/material.dart';
import 'package:melotune/locator.dart';
import 'package:melotune/services/backend/data_service.dart';
import 'package:melotune/utils/colors.dart';
import 'package:melotune/utils/strings.dart';

// ignore: must_be_immutable
class SearchBarWidget extends StatelessWidget {
  SearchBarWidget({super.key, this.myFocusNode});
  FocusNode? myFocusNode;
  String _oldValue = "";
  final _tSearch = TextEditingController();

  void _search(BuildContext context, String text) {
    myFocusNode?.unfocus();
    locator.get<DataService>().search(text).then((_) => _tSearch.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      color: KColors.appPrimary,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(7),
        ),
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: Autocomplete<String>(
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  myFocusNode = focusNode;
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onChanged: (value) {
                      if (_oldValue.isNotEmpty && value.isEmpty) {
                        Timer.periodic(const Duration(seconds: 1), (timer) {
                          myFocusNode?.unfocus();
                          timer.cancel();
                        });
                      } else {
                        _oldValue = value;
                      }
                      _tSearch.text = value;
                    },
                    onEditingComplete: () => onFieldSubmitted(),
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: KStrings.searchHint,
                      hintStyle: const TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) => Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 17),
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxHeight: 200, maxWidth: 240),
                          child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(12),
                              itemCount: options.length,
                              separatorBuilder: (context, i) => Divider(
                                    color: Colors.grey.withOpacity(.2),
                                  ),
                              itemBuilder: (BuildContext context, int index) {
                                String text = options.toList()[index];
                                return InkWell(
                                  onTap: () {
                                    _search(context, text);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                          color: KColors.softBlack),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    )),
                optionsBuilder: (textEditingValue) async {
                  return await locator
                      .get<DataService>()
                      .getAutoCompleteData(textEditingValue.text);
                },
              ),
            ),
            SizedBox(
              height: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _search(context, _tSearch.text);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(5)),
                  ),
                ),
                child: Text(
                  KStrings.searchBtn,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: KColors.appPrimary),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
