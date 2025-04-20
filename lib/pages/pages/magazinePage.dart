import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:derecho_en_perspectiva/pages/widgets/appBar.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:derecho_en_perspectiva/cubits/leafCubit.dart';

class MagazinePage extends StatefulWidget {
  const MagazinePage({Key? key}) : super(key: key);

  @override
  State<MagazinePage> createState() => _MagazinePageState();
}

class _MagazinePageState extends State<MagazinePage> {
  late final TurnPageController _flipCtrl;
  late final LeafCubit _leafCubit;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _flipCtrl = TurnPageController();
    _leafCubit = LeafCubit();

    // update cubit whenever the user drags a page
    _flipCtrl.addListener(() {
      _leafCubit.setLeaf(_flipCtrl.currentIndex);
    });
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _leafCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeafCubit>.value(
      value: _leafCubit,
      child: PdfDocumentViewBuilder.asset(
        'assets/pdf/flutter-succinctly.pdf',
        builder: (context, document) {
          if (document == null) {
            // show a centered spinner while we fetch + parse the PDF
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final totalPages = 84;
          final leafCount = (totalPages / 2).ceil();

          // init cubit once
          if (!_didInit) {
            _leafCubit.init(leafCount);
            _didInit = true;
          }

          return Scaffold(
            appBar: appBar(context),
            backgroundColor: AppColors.tan,
            body: Stack(
              children: [
                // ── Your Flipbook ──────────────────────────────────
                // ── Progress Bar AT THE TOP ─────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: BlocBuilder<LeafCubit, LeafState>(
                    builder: (_, state) {
                      return LinearProgressIndicator(
                        value: (state.currentLeaf + 1) / state.totalLeaves,
                        backgroundColor: Colors.white24,
                        color: AppColors.caputMortuum,
                        minHeight: 6,
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: TurnPageView.builder(
                    controller: _flipCtrl,
                    itemCount: leafCount,
                    itemBuilder: (ctx, leafIndex) {
                      final left = leafIndex * 2 + 1;
                      final right = left + 1;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Row(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PdfPageView(
                              document: document,
                              pageNumber: left,
                              decoration: BoxDecoration(
        color: Colors.white,         // ensure clean white page
        boxShadow: [],               // *no* shadows
        border: Border.all(color: Colors.transparent),
      ),
                            ),
                            const SizedBox(width: 8),
                            right <= totalPages
                                ? PdfPageView(
                                    document: document,
                                    pageNumber: right,
                                    decoration: BoxDecoration(
        color: Colors.white,         // ensure clean white page
        boxShadow: [],               // *no* shadows
        border: Border.all(color: Colors.transparent),
      ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      );
                    },
                    overleafColorBuilder: (_) => Colors.white,
                  ),
                ),

                // ── Prev Button on Left Edge ──────────────────────
                // 2) PREV BUTTON: left‑center
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: FloatingActionButton(
                      heroTag: 'prev',
                      mini: true,
                      child: const Icon(Icons.chevron_left),
                      onPressed: () {
                        final prev = (_flipCtrl.currentIndex - 1)
                            .clamp(0, leafCount - 1);
                        _flipCtrl.jumpToPage(prev);
                        _leafCubit.setLeaf(prev);
                      },
                    ),
                  ),
                ),

                // ── Next Button on Right Edge ─────────────────────
                // 3) NEXT BUTTON: right‑center
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: FloatingActionButton(
                      heroTag: 'next',
                      mini: true,
                      child: const Icon(Icons.chevron_right),
                      onPressed: () {
                        final next = (_flipCtrl.currentIndex + 1)
                            .clamp(0, leafCount - 1);
                        _flipCtrl.jumpToPage(next);
                        _leafCubit.setLeaf(next);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
