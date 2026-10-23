import 'package:flutter/material.dart';
import 'package:ystu_schedule/setup/model.dart';

class Guide extends StatelessWidget {
  static const guideCount = 4;

  final SetupModel setupModel;

  const Guide(this.setupModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pageController = PageController();

    final pages = <Widget>[];
    for (var i = 0; i < guideCount; i++) {
      final image = Image.asset('images/guide$i.png', height: 600);

      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            spacing: 10,
            children: [
              image,
              Row(
                children: [
                  Expanded(
                    child: i != guideCount - 1
                        ? ElevatedButton(
                            onPressed: () {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutQuart,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              foregroundColor: colorScheme.onSurface,
                            ),
                            child: const Text('Дальше'),
                          )
                        : ElevatedButton(
                            onPressed: setupModel.finishSetup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                            child: const Text('Понятно'),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Гайд'), centerTitle: true),
      body: Center(
        child: PageView(children: pages, controller: pageController),
      ),
    );
  }
}
