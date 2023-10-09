import 'package:admin_panel/locator.dart';
import 'package:admin_panel/services/backend/data_service.dart';
import 'package:admin_panel/services/providers/ringtones_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/global/input_widget.dart';

class RingtonesTab extends StatefulWidget {
  const RingtonesTab({super.key});

  @override
  State<RingtonesTab> createState() => _RingtonesTabState();
}

class _RingtonesTabState extends State<RingtonesTab> {
  final _tTitle = TextEditingController();
  final _tImage = TextEditingController();
  final _tUrl = TextEditingController();

  @override
  void initState() {
    locator.get<DataService>().getRingtones();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
              child: Consumer<RingtonesProvider>(
            builder: (context, value, child) => ListView.builder(
                itemCount: value.ringtones.length,
                itemBuilder: (context, index) {
                  final Map ringtone = value.ringtones[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: ListTile(
                      title: Text(ringtone['title']),
                      subtitle: Text(ringtone['url']),
                      leading: Image.network(ringtone['image']),
                      tileColor: Colors.white10,
                      trailing: ringtone.containsKey("id")
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => locator
                                  .get<DataService>()
                                  .removeRingtone(ringtone['id']),
                            )
                          : null,
                    ),
                  );
                }),
          )),
          _bottomInput(),
        ],
      ),
    );
  }

  Widget _bottomInput() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: InputWidget(
            hintText: "Başlık",
            controller: _tTitle,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          flex: 2,
          child: InputWidget(hintText: "URL", controller: _tUrl),
        ),
        const SizedBox(width: 5),
        Expanded(
          flex: 2,
          child: InputWidget(hintText: "Resim", controller: _tImage),
        ),
        IconButton(
          onPressed: () async {
            await locator
                .get<DataService>()
                .insertRingtone(_tTitle.text, _tUrl.text, _tImage.text);
            _tTitle.clear();
            _tUrl.clear();
            _tImage.clear();
          },
          icon: const Icon(Icons.arrow_circle_up_outlined, size: 30),
        ),
      ],
    );
  }
}
