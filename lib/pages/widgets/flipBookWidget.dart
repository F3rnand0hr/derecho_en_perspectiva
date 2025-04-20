import 'package:flutter/material.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

class FlipBook extends StatelessWidget {
  final List<Widget> pages; // e.g. Image.memory(...) for each PDF page

  const FlipBook({required this.pages, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TurnPageController();

    return Scaffold(
      body: TurnPageView.builder(
        controller: controller,
        itemCount: pages.length,
        itemBuilder: (ctx, index) => pages[index],
        overleafColorBuilder: (idx) => Colors.grey.shade200,
        animationTransitionPoint: 0.5, // when the page “folds”
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'prev',
            child: Icon(Icons.chevron_left),
            onPressed: () => controller.previousPage(),
          ),
          SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'next',
            child: Icon(Icons.chevron_right),
            onPressed: () => controller.nextPage(),
          ),
        ],
      ),
    );
  }
}
