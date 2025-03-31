import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:derecho_en_perspectiva/cubits/authCubit.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:derecho_en_perspectiva/repositories/articles/articlesRepository.dart';
import 'package:derecho_en_perspectiva/repositories/articles/articleLoader.dart';

class LikeButton extends StatelessWidget {
  final String articleId;

  const LikeButton({Key? key, required this.articleId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ArticleLoader(
      articleId: articleId,
      builder: (context, article) {
        final liked = article.liked;
        final authState = context.read<AuthCubit>().state;
        final uid = authState?.uid;
        return IconButton(
          icon: Icon(
            liked.contains(uid) ? Icons.favorite : Icons.favorite_border,
            color: liked.contains(uid) ? Colors.red : AppColors.spaceCadet,
          ),
          onPressed: uid == null
              ? null
              : () async {
                  final repo = ArticleRepository();
                  if (liked.contains(uid)) {
                    await repo.unlikeArticle(articleId, uid);
                  } else {
                    await repo.likeArticle(articleId, uid);
                  }
                },
        );
      },
    );
  }
}
