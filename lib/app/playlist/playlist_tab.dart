import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/player/mini_player_sheet.dart';
import 'package:tube_sync/app/playlist/media_entry_builder.dart';
import 'package:tube_sync/app/playlist/playlist_header.dart';
import 'package:tube_sync/model/media.dart';
import 'package:tube_sync/provider/player_provider.dart';
import 'package:tube_sync/provider/playlist_provider.dart';

class PlaylistTab extends StatefulWidget {
  const PlaylistTab({super.key});

  @override
  State<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> refreshIndicator = GlobalKey();

  Future<void> refreshHandler({bool emitError = false}) async {
    try {
      await context.read<PlaylistProvider>().refresh();
    } catch (err) {
      if (!mounted || !emitError) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<PlaylistProvider>().medias.isNotEmpty) {
        // Silently try to refresh
        refreshHandler(emitError: false);
      } else {
        refreshIndicator.currentState?.show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      primary: false,
      body: Consumer<PlaylistProvider>(
        child: PlaylistHeader(onPlayAll: () => launchPlayer()),
        builder: (context, playlist, header) => RefreshIndicator(
          key: refreshIndicator,
          onRefresh: refreshHandler,
          child: ListView.builder(
            itemCount: playlist.medias.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return header;
              return MediaEntryBuilder(
                playlist.medias[index - 1],
                onTap: () => launchPlayer(
                  initialMedia: playlist.medias[index - 1],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void launchPlayer({Media? initialMedia}) {
    scaffold?.showBottomSheet(
      (_) => Provider<PlayerProvider>(
        create: (_) => PlayerProvider(
          context.read<PlaylistProvider>(),
          start: initialMedia,
        ),
        dispose: (_, provider) => provider.dispose(),
        child: MiniPlayerSheet(),
      ),
      enableDrag: false,
      shape: InputBorder.none,
      elevation: 0,
    );
  }

  ScaffoldState? get scaffold =>
      context.read<GlobalKey<ScaffoldState>>().currentState;

  @override
  bool get wantKeepAlive => true;
}
