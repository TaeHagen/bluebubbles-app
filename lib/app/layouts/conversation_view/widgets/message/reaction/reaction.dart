import 'dart:async';

import 'package:bluebubbles/app/layouts/conversation_view/widgets/message/popup/message_popup.dart';
import 'package:bluebubbles/app/layouts/conversation_view/widgets/message/reaction/reaction_clipper.dart';
import 'package:bluebubbles/app/wrappers/stateful_boilerplate.dart';
import 'package:bluebubbles/helpers/helpers.dart';
import 'package:bluebubbles/main.dart';
import 'package:bluebubbles/models/models.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ReactionWidget extends StatefulWidget {
  const ReactionWidget({
    Key? key,
    required this.messageIsFromMe,
    required this.reaction,
    this.reactions,
  }) : super(key: key);

  final bool messageIsFromMe;
  final Message reaction;
  final List<Message>? reactions;

  @override
  ReactionWidgetState createState() => ReactionWidgetState();
}

class ReactionWidgetState extends OptimizedState<ReactionWidget> {
  late Message reaction = widget.reaction;
  late final StreamSubscription<Query<Message>> sub;

  List<Message>? get reactions => widget.reactions;
  bool get reactionIsFromMe => reaction.isFromMe!;
  bool get messageIsFromMe => widget.messageIsFromMe;
  String get reactionType => reaction.associatedMessageType!;

  static const double iosSize = 35;

  @override
  void initState() {
    super.initState();
    updateObx(() {
      if (!kIsWeb) {
        final messageQuery = messageBox.query(Message_.id.equals(reaction.id!)).watch();
        sub = messageQuery.listen((Query<Message> query) async {
          final _message = await runAsync(() {
            return messageBox.get(reaction.id!);
          });
          if (_message != null) {
            if (_message.guid != reaction.guid || _message.dateDelivered != reaction.dateDelivered) {
              setState(() {
                reaction = _message;
              });
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ss.settings.skin.value != Skins.iOS) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: reactionIsFromMe ? context.theme.colorScheme.primary : context.theme.colorScheme.properSurface,
          border: Border.all(color: context.theme.colorScheme.background),
          shape: BoxShape.circle,
        ),
        child: GestureDetector(
          onTap: () {
            if (reactions == null) return;
            for (Message m in reactions!) {
              if (!m.isFromMe!) {
                m.handle ??= m.getHandle();
              }
            }
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                    child: Theme(
                      data: context.theme.copyWith(
                        // in case some components still use legacy theming
                        primaryColor: context.theme.colorScheme.bubble(context, true),
                        colorScheme: context.theme.colorScheme.copyWith(
                          primary: context.theme.colorScheme.bubble(context, true),
                          onPrimary: context.theme.colorScheme.onBubble(context, true),
                          surface: ss.settings.monetTheming.value == Monet.full ? null : (context.theme.extensions[BubbleColors] as BubbleColors?)?.receivedBubbleColor,
                          onSurface: ss.settings.monetTheming.value == Monet.full ? null : (context.theme.extensions[BubbleColors] as BubbleColors?)?.onReceivedBubbleColor,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Positioned(
                            bottom: 10,
                            left: 15,
                            right: 15,
                            child: ReactionDetails(reactions: reactions!)
                          ),
                        ],
                      ),
                    ),
                  );
                },
                fullscreenDialog: true,
                opaque: false,
                barrierDismissible: true,
              ),
            );
          },
          child: Center(
            child: Text(
              ReactionTypes.reactionToEmoji[reactionType] ?? "X",
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
        )
      );
    }
    return Stack(
      alignment: messageIsFromMe ? Alignment.centerRight : Alignment.centerLeft,
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -1,
          left: messageIsFromMe ? 0 : -1,
          right: !messageIsFromMe ? 0 : -1,
          child: ClipPath(
            clipper: ReactionBorderClipper(isFromMe: messageIsFromMe),
            child: Container(
              width: iosSize + 2,
              height: iosSize + 2,
              color: context.theme.colorScheme.background,
            ),
          ),
        ),
        ClipPath(
          clipper: ReactionClipper(isFromMe: messageIsFromMe),
          child: Container(
            width: iosSize,
            height: iosSize,
            color: reactionIsFromMe
                ? context.theme.colorScheme.primary.darkenAmount(reaction.guid!.startsWith("temp") ? 0.2 : 0)
                : context.theme.colorScheme.properSurface,
            alignment: messageIsFromMe ? Alignment.topRight : Alignment.topLeft,
            child: SizedBox(
              width: iosSize*0.8,
              height: iosSize*0.8,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(6.5).add(EdgeInsets.only(right: reactionType == "emphasize" ? 1 : 0)),
                  child: SvgPicture.asset(
                    'assets/reactions/$reactionType-black.svg',
                    color: reactionType == "love"
                        ? Colors.pink
                        : (reactionIsFromMe ? context.theme.colorScheme.onPrimary : context.theme.colorScheme.properOnSurface),
                  ),
                )
              ),
            )
          )
        ),
        Positioned(
          left: !messageIsFromMe ? 0 : -75,
          right: messageIsFromMe ? 0 : -75,
          child: Obx(() {
            if (reaction.error > 0 || reaction.guid!.startsWith("error-")) {
              int errorCode = reaction.error;
              String errorText = "An unknown internal error occurred.";
              if (errorCode == 22) {
                errorText = "The recipient is not registered with iMessage!";
              } else if (reaction.guid!.startsWith("error-")) {
                errorText = reaction.guid!.split('-')[1];
              }

              return DeferPointer(
                child: GestureDetector(
                  child: Icon(
                    ss.settings.skin.value == Skins.iOS ? CupertinoIcons.exclamationmark_circle : Icons.error_outline,
                    color: context.theme.colorScheme.error,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: context.theme.colorScheme.properSurface,
                          title: Text("Message failed to send", style: context.theme.textTheme.titleLarge),
                          content: Text("Error ($errorCode): $errorText", style: context.theme.textTheme.bodyLarge),
                          actions: <Widget>[
                            TextButton(
                              child: Text(
                                  "Retry",
                                  style: context.theme.textTheme.bodyLarge!.copyWith(color: Get.context!.theme.colorScheme.primary)
                              ),
                              onPressed: () async {
                                // Remove the original message and notification
                                Navigator.of(context).pop();
                                Message.delete(reaction.guid!);
                                await notif.clearFailedToSend();
                                getActiveMwc(reaction.associatedMessageGuid!)?.removeAssociatedMessage(reaction);
                                // Re-send
                                final selected = getActiveMwc(reaction.associatedMessageGuid!)!.message;
                                outq.queue(OutgoingItem(
                                  type: QueueType.sendMessage,
                                  chat: cm.activeChat!.chat,
                                  message: Message(
                                    associatedMessageGuid: selected.guid,
                                    associatedMessageType: reaction.associatedMessageType,
                                    dateCreated: DateTime.now(),
                                    hasAttachments: false,
                                    isFromMe: true,
                                    handleId: 0,
                                  ),
                                  selected: selected,
                                  reaction: reaction.associatedMessageType!,
                                ));
                              },
                            ),
                            TextButton(
                              child: Text(
                                  "Remove",
                                  style: context.theme.textTheme.bodyLarge!.copyWith(color: Get.context!.theme.colorScheme.primary)
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                // Delete the message from the DB
                                Message.delete(reaction.guid!);
                                // Remove the message from the Bloc
                                getActiveMwc(reaction.associatedMessageGuid!)?.removeAssociatedMessage(reaction);
                                await notif.clearFailedToSend();
                                // Get the "new" latest info
                                final chat = cm.activeChat!.chat;
                                List<Message> latest = Chat.getMessages(chat, limit: 1);
                                chat.latestMessage = latest.first;
                                chat.save();
                              },
                            ),
                            TextButton(
                              child: Text(
                                  "Cancel",
                                  style: context.theme.textTheme.bodyLarge!.copyWith(color: Get.context!.theme.colorScheme.primary)
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await notif.clearFailedToSend();
                              },
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        )
      ],
    );
  }
}
