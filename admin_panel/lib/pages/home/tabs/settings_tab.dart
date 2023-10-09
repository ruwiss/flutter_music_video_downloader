import 'package:admin_panel/locator.dart';
import 'package:admin_panel/services/backend/data_service.dart';
import 'package:flutter/material.dart';

import '../../../widgets/global/input_widget.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _tName = TextEditingController();

  final _tValue = TextEditingController();

  _selectItem(Map item) {
    _tName.text = item['name'];
    _tValue.text = item['value'];
  }

  _setValue() async {
    locator.get<DataService>().setAppSettings(_tName.text, _tValue.text).then(
      (value) {
        if (value) {
          _tName.clear();
          _tValue.clear();
          setState(() {});
        }
      },
    );
  }

  _deleteSetting(String name) async {
    locator.get<DataService>().deleteAppSetting(name).then(
      (value) {
        if (value) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List>(
              future: locator.get<DataService>().getAppSettings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '${snapshot.error}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data![index];
                        return ListTile(
                          title: Text("${data['name']} => ${data['value']}"),
                          leading: IconButton(
                            onPressed: () => _selectItem(data),
                            icon: const Icon(Icons.edit, size: 20),
                          ),
                          trailing: IconButton(
                            onPressed: () => _deleteSetting(data['name']),
                            icon: const Icon(Icons.close, size: 20),
                          ),
                        );
                      },
                    );
                  }
                }
                return const SizedBox();
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InputWidget(hintText: "İsim", controller: _tName),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: InputWidget(hintText: "Değer", controller: _tValue),
              ),
              IconButton(
                  onPressed: () => _setValue(),
                  icon: const Icon(Icons.arrow_circle_up_outlined, size: 30)),
            ],
          ),
        ],
      ),
    );
  }
}
