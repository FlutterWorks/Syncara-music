import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as mk;
import 'package:provider/provider.dart';
import 'package:syncara/app/player/components/action_buttons.dart';
import 'package:syncara/app/player/components/seekbar.dart';
import 'package:syncara/app/player/components/sleep_time_indicator.dart';
import 'package:syncara/clients/media_client.dart';
import 'package:syncara/provider/player_provider.dart';

class Video extends StatefulWidget {
  const Video({super.key});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> with AutomaticKeepAliveClientMixin {
  late final GlobalKey<mk.VideoState> video = GlobalKey<mk.VideoState>();
  late final player = Player(
      configuration: const PlayerConfiguration(
    muted: true,
  ));
  late final controller = mk.VideoController(player);

  @override
  void initState() {
    super.initState();
    musicPlayer.nowPlaying.addListener(loadVideoTrack);
    loadVideoTrack();
    player.setAudioTrack(AudioTrack.no());
  }

  String status = "";

  void loadVideoTrack() async {
    try {
      setState(() => status = "Fetching....");
      final nowPlaying = musicPlayer.nowPlaying.value;
      final tracks = await MediaClient().getVideoTracks(nowPlaying);
      if (!mounted) {
        musicPlayer.nowPlaying.removeListener(loadVideoTrack);
        return;
      }

      player.open(tracks.first);
      status = tracks.first.extras.toString();
      print(status);

    } catch (e) {
      status = e.toString();
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: mk.Video(
              key: video,
              controller: controller,
              controls: fullscreenControls,
            ),
          ),
        ),
        controls,
      ],
    );
  }

  Widget get controls {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () => video.currentState?.enterFullscreen(),
              icon: const Icon(Icons.fullscreen_rounded),
            ),
          ],
        ),
      ),
    );
  }

  CrossFadeState fullscreenOSD = CrossFadeState.showSecond;

  Widget fullscreenControls(mk.VideoState state) {
    if (!state.isFullscreen()) return const SizedBox();

    return AnimatedCrossFade(
      crossFadeState: fullscreenOSD,
      duration: Durations.extralong4,
      firstChild: SizedBox.fromSize(
        size: MediaQuery.of(context).size,
        child: InkWell(
          onTap: () => state.setState(
            () => fullscreenOSD = CrossFadeState.showSecond,
          ),
        ),
      ),
      secondChild: SizedBox.fromSize(
        size: MediaQuery.of(context).size,
        child: InkWell(
          onTap: () => state.setState(
            () => fullscreenOSD = CrossFadeState.showFirst,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ChangeNotifierProvider<PlayerProvider>.value(
              value: musicPlayer,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          musicPlayer.nowPlaying.value.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SleepTimeIndicator(),
                      IconButton(
                        onPressed: () => state.exitFullscreen(),
                        icon: const Icon(Icons.fullscreen_exit_rounded),
                      ),
                    ],
                  ),
                  const Expanded(child: ActionButtons()),
                  const Row(
                    children: [
                      Expanded(child: SeekBar()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PlayerProvider get musicPlayer {
    return context.read<PlayerProvider>();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive {
    return player.state.buffer > Duration.zero;
  }
}
