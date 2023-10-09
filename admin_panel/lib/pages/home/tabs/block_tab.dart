import 'package:admin_panel/locator.dart';
import 'package:admin_panel/services/backend/data_service.dart';
import 'package:admin_panel/services/providers/block_provider.dart';
import 'package:admin_panel/widgets/global/input_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlockMusicTab extends StatefulWidget {
  const BlockMusicTab({super.key});

  @override
  State<BlockMusicTab> createState() => _BlockMusicTabState();
}

class _BlockMusicTabState extends State<BlockMusicTab> {
  final _blockInputController = TextEditingController();

  @override
  void initState() {
    locator.get<DataService>().getBlockedMusics();
    super.initState();
  }

  @override
  void dispose() {
    _blockInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Engellenen ID Listesi"),
              Row(
                children: [
                  Text(Provider.of<BlockProvider>(context).insertTime),
                  const SizedBox(width: 10),
                  OutlinedButton(
                      onPressed: () =>
                          locator.get<DataService>().setBlockedMusics(),
                      child: const Text("KAYDET")),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Consumer<BlockProvider>(
                builder: (context, value, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(value.blockedList.length, (index) {
                    final String blockedId = value.blockedList[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration:
                          BoxDecoration(color: Colors.white.withOpacity(.02)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(blockedId),
                          IconButton(
                              onPressed: () =>
                                  value.removeFromBlockedList(blockedId),
                              icon: const Icon(Icons.close, size: 20))
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          InputWidget(
            controller: _blockInputController,
            hintText: "Youtube ID",
            onTap: () {
              locator
                  .get<BlockProvider>()
                  .addToBlockedList(_blockInputController.text);
              _blockInputController.clear();
            },
          )
        ],
      ),
    );
  }
}
