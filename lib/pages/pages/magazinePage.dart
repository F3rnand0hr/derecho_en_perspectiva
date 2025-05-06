import 'package:derecho_en_perspectiva/data/data_source/device_info/device_height.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:derecho_en_perspectiva/pages/widgets/appBar.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:derecho_en_perspectiva/cubits/leafCubit.dart';

class MagazinePage extends StatefulWidget {
  const MagazinePage({super.key});

  @override
  State<MagazinePage> createState() => _MagazinePageState();
}

class _MagazinePageState extends State<MagazinePage> {
  late final TurnPageController _flipCtrl;
  late final LeafCubit _leafCubit;
  bool _didInit = false;
  bool _isNarrow = false;

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
  Widget build(BuildContext context) {
    return BlocProvider<LeafCubit>.value(
      value: _leafCubit,
      child: PdfDocumentViewBuilder.asset(
        'assets/pdf/flutter-succinctly.pdf',
        builder: (context, document) {

          final isNarrow = deviceWidth(context) < 890;

          if (document == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final totalPages = 84;
          final leafCount = (totalPages / 2).ceil();

          if (!_didInit) {
            _leafCubit.init(leafCount);
            _didInit = true;
          }

          return Scaffold(
            appBar: appBar(context),
            backgroundColor: AppColors.darkBlack,
            body: Column(
              children: [
                // — Progress bar —
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BlocBuilder<LeafCubit, LeafState>(
                    builder: (_, state) => LinearProgressIndicator(
                      value: (state.currentLeaf + 1) / state.totalLeaves,
                      backgroundColor: Colors.white24,
                      color: AppColors.caputMortuum,
                      minHeight: 6,
                    ),
                  ),
                ),

                // — Flipbook with lazy loading —
                Expanded(
                  child: Stack(
                    children: [
                      // 1) Wrap your TurnPageView in a BlocBuilder so you know the current leaf
                      Positioned.fill(
                        child: BlocBuilder<LeafCubit, LeafState>(
                          builder: (context, leafState) {
                            return TurnPageView.builder(
                              controller: _flipCtrl,
                              itemCount: leafCount,
                              itemBuilder: (ctx, leafIndex) {
                                // If this leaf is more than 1 away from the current,
                                // just return a placeholder
                                if ((leafIndex - leafState.currentLeaf).abs() > 1) {
                                  return Container(
                                    color: AppColors.darkBlack,
                                  );
                                }

                                if (isNarrow) {
                                  final pageNum = leafIndex + 1;
                                  final ref = document.pages[pageNum - 1];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 20),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 100),
                                        AspectRatio(
                                          aspectRatio: ref.width / ref.height,
                                          child: PdfPageView(
                                            document: document,
                                            pageNumber: pageNum,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.transparent),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Two‐page spread for wide screens
                                final left = leafIndex * 2 + 1;
                                final right = left + 1;
                                final leftRef = document.pages[left - 1];
                                final rightRef = right <= totalPages
                                    ? document.pages[right - 1]
                                    : null;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: leftRef.width / leftRef.height,
                                        child: PdfPageView(
                                          document: document,
                                          pageNumber: left,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (rightRef != null)
                                        AspectRatio(
                                          aspectRatio:
                                              rightRef.width / rightRef.height,
                                          child: PdfPageView(
                                            document: document,
                                            pageNumber: right,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(color: Colors.black),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                              overleafColorBuilder: (_) => Colors.white,
                            );
                          },
                        ),
                      ),

                      // 2 & 3) Prev / Next buttons (unchanged)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left),
                          color: AppColors.caputMortuum,
                          onPressed: () {
                            final prev = (_flipCtrl.currentIndex - 1)
                                .clamp(0, leafCount - 1);
                            _flipCtrl.jumpToPage(prev);
                            _leafCubit.setLeaf(prev);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right),
                          color: AppColors.caputMortuum,
                          onPressed: () {
                            final next = (_flipCtrl.currentIndex + 1)
                                .clamp(0, leafCount - 1);
                            _flipCtrl.jumpToPage(next);
                            _leafCubit.setLeaf(next);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }}
