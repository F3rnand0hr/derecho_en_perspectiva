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
            backgroundColor: AppColors.creamBeige,
            body: Column(
              children: [
                // — Progress bar at the very top —
                BlocBuilder<LeafCubit, LeafState>(
                  builder: (_, state) => LinearProgressIndicator(
                    value: (state.currentLeaf + 1) / state.totalLeaves,
                    backgroundColor: Colors.white24,
                    color: AppColors.caputMortuum,
                    minHeight: 6,
                  ),
                ),

                // — Flipbook takes the rest of the screen —
              
                  Expanded(
                    child: Stack(
                      children: [
                        // 1) The TurnPageView in a bounded container:
                        Positioned.fill(
                          child: TurnPageView.builder(
                            controller: _flipCtrl,
                            itemCount: leafCount,
                            itemBuilder: (ctx, leafIndex) {
                              // detect screen width
                              final screenW = MediaQuery.of(context).size.width;
                              final isNarrow = screenW < 890;
                              final viewCount = isNarrow ? totalPages : leafCount;
                  
                              // single‑page for narrow
                              if (isNarrow) {
                                final pageNum = leafIndex + 1;
                                final ref = document.pages[pageNum - 1];
                  
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 20),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                      ),
                                      AspectRatio(
                                        aspectRatio: ref.width / ref.height,
                                        child: PdfPageView(
                                          document: document,
                                          pageNumber: pageNum,
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .white, // ensure clean white page
                                            border: Border.all(
                                                color: Colors.transparent),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final left = leafIndex * 2 + 1;
                              final right = left + 1;
                              // grab your PdfPageRefs for aspect ratio
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
                                          color: Colors
                                              .white, // ensure clean white page
                                          border: Border.all(
                                              color: Colors.black),
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
                                            color: Colors
                                                .white, // ensure clean white page
                                            border: Border.all(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                            overleafColorBuilder: (_) => Colors.white,
                          ),
                        ),
                  
                        // 2) Prev button on the left
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
                  
                        // 3) Next button on the right
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
  }
}
