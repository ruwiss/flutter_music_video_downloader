import 'package:admin_panel/locator.dart';
import 'package:admin_panel/services/backend/data_service.dart';
import 'package:flutter/material.dart';

class LanguageTab extends StatefulWidget {
  const LanguageTab({super.key});

  @override
  State<LanguageTab> createState() => _LanguageTabState();
}

class _LanguageTabState extends State<LanguageTab> {
  Container _listItem(String t1, String t2, {bool colored = false}) {
    final textStyle = TextStyle(color: colored ? Colors.amber : null);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.02)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t1, style: textStyle),
          Text(t2, style: textStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Günlük İstekler"),
          const SizedBox(height: 20),
          _listItem("Dil Kodu", "Giriş Sayısı", colored: true),
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder<List>(
                future: locator.get<DataService>().getLanguageRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Bekleyiniz..");
                  } else if (!snapshot.hasData) {
                    return const Text("Bir sorun oluştu");
                  } else if (snapshot.data!.isEmpty) {
                    return const Text("Henüz veri yok");
                  } else {
                    final data = snapshot.data!;
                    final total = snapshot.data!
                        .map((e) => e["count"])
                        .reduce((a, b) => a + b);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...List.generate(
                          data.length,
                          (index) {
                            final item = data[index];
                            return _listItem(
                                item["lang"], item["count"].toString());
                          },
                        ).toList(),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, right: 15),
                          child:
                              Text("Toplam: $total", textAlign: TextAlign.end),
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
