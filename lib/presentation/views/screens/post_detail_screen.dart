import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_journals/data/models/post_model.dart';

import '../../../data/models/user_model.dart';
import '../../viewmodels/cubit/post_cubit/cubit.dart';
import '../../viewmodels/cubit/post_cubit/state.dart';
import '../widgets/cache_network_image.dart';

class PostDetailsOverlay extends StatefulWidget {
  const PostDetailsOverlay({super.key, required this.post, required this.user});

  final PostModel post;
  final UserModel? user;

  @override
  State<PostDetailsOverlay> createState() => _PostDetailsOverlayState();
}

class _PostDetailsOverlayState extends State<PostDetailsOverlay>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 600);
  static const _cardHeight = 0.2; // card height to display post information
  static const _imageHeight = 0.6; // image height to display post

  late final Animation<double> _animation;
  late final AnimationController _controller;

  @override
  void dispose() {
    _controller
      ..reverse()
      ..dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimation(); // initialization animation, to make screen more user appealing.
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  Widget _buildTopButtons() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Icon(Icons.more_vert, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<PostDetailCubit, PostDetailState>(
      // whenever state is change, either post like one or card view expanding, it rebuild the widgets
      builder:
          (context, state) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all<Color>(Colors.blue),
                  shadowColor: WidgetStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                  surfaceTintColor: WidgetStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                  minimumSize: WidgetStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width * 0.25, 40),
                  ),
                ),
                onPressed:
                    () => context.read<PostDetailCubit>().toggleLiked(
                      widget.post.postId,
                    ),
                icon: Icon(
                  Icons.thumb_up,
                  color: state.isLiked ? Colors.blue : Colors.white,
                ),
                label: Text(
                  'Like',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: state.isLiked ? Colors.blue : Colors.white,
                  ),
                ),
              ),
              TextButton.icon(
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all<Color>(
                    Colors.greenAccent,
                  ),
                  shadowColor: WidgetStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                  surfaceTintColor: WidgetStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                  minimumSize: WidgetStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width * 0.25, 40),
                  ),
                ),
                onPressed:
                    () => context.read<PostDetailCubit>().sharePost(
                      context,
                      widget.post.postUrl,
                    ),
                icon: const Icon(Icons.send, color: Colors.white),
                label: Text(
                  "Share",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildExpandableDescription(
    BuildContext context,
    String text,
    bool isExpand,
  ) {
    final formattedTime = _timeFormat(
      widget.post.postTimeStamp.toDate().toString(),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final TextSpan textSpan = TextSpan(
          text: text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        );

        final TextPainter textPainter = TextPainter(
          text: textSpan,
          maxLines: isExpand ? null : 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final bool isTextOverflowing =
            textPainter
                .didExceedMaxLines; // if the post description is taking more than provided space then it will display ellipsis and see more option to seeing the full text

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              maxLines: isExpand ? null : 2,
              overflow: isExpand ? null : TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (isTextOverflowing || isExpand)
              GestureDetector(
                onTap: () {
                  context.read<PostDetailCubit>().toggleExpand(isExpand);
                },
                child: Text(
                  isExpand ? 'See Less' : 'See More',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Text(
              formattedTime,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  Widget _cardBlock({required bool isExpand}) {
    final Size size = MediaQuery.of(context).size;

    return Card(
      color: Colors.black26,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      elevation: 10,
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: size.height * (_cardHeight * (isExpand ? 1.5 : 1.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ).copyWith(top: 5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user!.userName.toString(),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
              isExpand
                  ? SizedBox(
                    height: size.height * _cardHeight,
                    width: size.width,
                    child: SingleChildScrollView(
                      child: _buildExpandableDescription(
                        context,
                        widget.post.postDescription,
                        true,
                      ),
                    ),
                  )
                  : Flexible(
                    child: _buildExpandableDescription(
                      context,
                      widget.post.postDescription,
                      false,
                    ),
                  ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  String _timeFormat(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);

    // List of month names
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    // Get day with leading zero if needed
    String day = dateTime.day.toString().padLeft(2, '0');
    // Get month name
    String month = months[dateTime.month - 1];
    // Get year
    String year = dateTime.year.toString();

    return '$day-$month-$year';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomCenter,
          children: [
            // Center Image
            Positioned(
              bottom:
                  (size.height -
                      (size.height * _cardHeight) -
                      (size.height * _imageHeight)),
              left: 0,
              right: 0,
              child: CacheNetworkImage().buildNetworkImage(
                context,
                imgUrl: widget.post.postUrl,
                height: size.height * _imageHeight,
              ),
            ),
            // Bottom Card
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BlocBuilder<PostDetailCubit, PostDetailState>(
                builder: (context, state) {
                  if (state.isExpand) {
                    return _cardBlock(isExpand: true);
                  } else {
                    return _cardBlock(isExpand: false);
                  }
                },
              ),
            ),

            _buildTopButtons(),
          ],
        ),
      ),
    );
  }
}
