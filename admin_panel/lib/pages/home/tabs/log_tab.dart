import 'package:admin_panel/locator.dart';
import 'package:admin_panel/services/backend/data_service.dart';
import 'package:flutter/material.dart';

class LogTab extends StatefulWidget {
  const LogTab({super.key});

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder<String>(
                future: locator.get<DataService>().getLogData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Bekleyiniz..");
                  } else if (!snapshot.hasData) {
                    return const Text("Bir sorun oluştu");
                  } else {
                    return Text(
                      snapshot.data!,
                      style: const TextStyle(color: Colors.white54),
                    );
                  }
                },
              ),
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                  onPressed: () =>
                      locator.get<DataService>().clearLogData().then((value) {
                        if (value) setState(() {});
                      }),
                  child: const Text("Temizle")))
        ],
      ),
    );
  }
}
