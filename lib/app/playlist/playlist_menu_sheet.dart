import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tube_sync/app/more/downloads/active_downloads_screen.dart';
import 'package:tube_sync/provider/playlist_provider.dart';

class PlaylistMenuSheet extends StatelessWidget {
  const PlaylistMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Drag Handle
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 4,
              width: kMinInteractiveDimension,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              context.read<PlaylistProvider>().downloadAll();
              ActiveDownloadsScreen.showEnqueuedSnackbar(context);
              Navigator.pop(context);
            },
            leading: Icon(Icons.download_rounded),
            title: Text("Download All"),
          ),
        ],
      ),
    );
  }
}
