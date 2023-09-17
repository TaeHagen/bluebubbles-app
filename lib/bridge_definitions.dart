// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.75.3.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;

part 'bridge_definitions.freezed.dart';

abstract class NativeLib {
  Future<PushState> newPushState({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kNewPushStateConstMeta;

  Future<String> formatE164(
      {required String number, required String country, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kFormatE164ConstMeta;

  Future<DartRecievedMessage?> recvWait(
      {required PushState state, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kRecvWaitConstMeta;

  Future<void> send(
      {required PushState state, required DartIMessage msg, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSendConstMeta;

  Future<List<String>> getHandles({required PushState state, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetHandlesConstMeta;

  Future<DartIMessage> newMsg(
      {required PushState state,
      required DartConversationData conversation,
      required DartMessage message,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kNewMsgConstMeta;

  Future<List<String>> validateTargets(
      {required PushState state, required List<String> targets, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kValidateTargetsConstMeta;

  Future<void> cancelRegistration({required PushState state, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kCancelRegistrationConstMeta;

  Future<RegistrationPhase> getPhase({required PushState state, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetPhaseConstMeta;

  Future<void> restore(
      {required PushState currState, required String data, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kRestoreConstMeta;

  Future<void> newPush({required PushState state, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kNewPushConstMeta;

  Stream<TransferProgress> downloadAttachment(
      {required PushState state,
      required DartAttachment attachment,
      required String path,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kDownloadAttachmentConstMeta;

  Stream<TransferProgress> downloadMmcs(
      {required PushState state,
      required DartMMCSFile attachment,
      required String path,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kDownloadMmcsConstMeta;

  Stream<MMCSTransferProgress> uploadMmcs(
      {required PushState state, required String path, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kUploadMmcsConstMeta;

  Stream<TransferProgress> uploadAttachment(
      {required PushState state,
      required String path,
      required String mime,
      required String uti,
      required String name,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kUploadAttachmentConstMeta;

  Future<int> tryAuth(
      {required PushState state,
      required String username,
      required String password,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kTryAuthConstMeta;

  Future<int> registerIds(
      {required PushState state, required String validationData, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kRegisterIdsConstMeta;

  Future<String> savePush({required PushState state, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSavePushConstMeta;

  Future<String> saveMethodDartAttachment(
      {required DartAttachment that, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSaveMethodDartAttachmentConstMeta;

  Future<DartAttachment> restoreStaticMethodDartAttachment(
      {required String saved, dynamic hint});

  FlutterRustBridgeTaskConstMeta
      get kRestoreStaticMethodDartAttachmentConstMeta;

  Future<int> getSizeMethodDartAttachment(
      {required DartAttachment that, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetSizeMethodDartAttachmentConstMeta;

  Future<String> asPlainMethodDartMessageParts(
      {required DartMessageParts that, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kAsPlainMethodDartMessagePartsConstMeta;

  DropFnType get dropOpaquePushState;
  ShareFnType get shareOpaquePushState;
  OpaqueTypeFinalizer get PushStateFinalizer;
}

@sealed
class PushState extends FrbOpaque {
  final NativeLib bridge;
  PushState.fromRaw(int ptr, int size, this.bridge) : super.unsafe(ptr, size);
  @override
  DropFnType get dropFn => bridge.dropOpaquePushState;

  @override
  ShareFnType get shareFn => bridge.shareOpaquePushState;

  @override
  OpaqueTypeFinalizer get staticFinalizer => bridge.PushStateFinalizer;
}

class DartAttachment {
  final NativeLib bridge;
  final DartAttachmentType aType;
  final int partIdx;
  final String utiType;
  final String mime;
  final String name;
  final bool iris;

  const DartAttachment({
    required this.bridge,
    required this.aType,
    required this.partIdx,
    required this.utiType,
    required this.mime,
    required this.name,
    required this.iris,
  });

  Future<String> save({dynamic hint}) => bridge.saveMethodDartAttachment(
        that: this,
      );

  static Future<DartAttachment> restore(
          {required NativeLib bridge, required String saved, dynamic hint}) =>
      bridge.restoreStaticMethodDartAttachment(saved: saved, hint: hint);

  Future<int> getSize({dynamic hint}) => bridge.getSizeMethodDartAttachment(
        that: this,
      );
}

@freezed
class DartAttachmentType with _$DartAttachmentType {
  const factory DartAttachmentType.inline(
    Uint8List field0,
  ) = DartAttachmentType_Inline;
  const factory DartAttachmentType.mmcs(
    DartMMCSFile field0,
  ) = DartAttachmentType_MMCS;
}

class DartBalloonBody {
  String bid;
  Uint8List data;

  DartBalloonBody({
    required this.bid,
    required this.data,
  });
}

class DartChangeParticipantMessage {
  final List<String> newParticipants;
  final int groupVersion;

  const DartChangeParticipantMessage({
    required this.newParticipants,
    required this.groupVersion,
  });
}

class DartConversationData {
  List<String> participants;
  String? cvName;
  String? senderGuid;

  DartConversationData({
    required this.participants,
    this.cvName,
    this.senderGuid,
  });
}

class DartEditMessage {
  final String tuuid;
  final int editPart;
  final DartMessageParts newParts;

  const DartEditMessage({
    required this.tuuid,
    required this.editPart,
    required this.newParts,
  });
}

class DartIMessage {
  String id;
  String? sender;
  String? afterGuid;
  DartConversationData? conversation;
  DartMessage message;
  int sentTimestamp;

  DartIMessage({
    required this.id,
    this.sender,
    this.afterGuid,
    this.conversation,
    required this.message,
    required this.sentTimestamp,
  });
}

class DartIconChangeMessage {
  final DartMMCSFile? file;
  final int groupVersion;

  const DartIconChangeMessage({
    this.file,
    required this.groupVersion,
  });
}

class DartIndexedMessagePart {
  final DartMessagePart field0;
  final int? field1;

  const DartIndexedMessagePart({
    required this.field0,
    this.field1,
  });
}

@freezed
class DartMessage with _$DartMessage {
  const factory DartMessage.message(
    DartNormalMessage field0,
  ) = DartMessage_Message;
  const factory DartMessage.renameMessage(
    DartRenameMessage field0,
  ) = DartMessage_RenameMessage;
  const factory DartMessage.changeParticipants(
    DartChangeParticipantMessage field0,
  ) = DartMessage_ChangeParticipants;
  const factory DartMessage.react(
    DartReactMessage field0,
  ) = DartMessage_React;
  const factory DartMessage.delivered() = DartMessage_Delivered;
  const factory DartMessage.read() = DartMessage_Read;
  const factory DartMessage.typing() = DartMessage_Typing;
  const factory DartMessage.unsend(
    DartUnsendMessage field0,
  ) = DartMessage_Unsend;
  const factory DartMessage.edit(
    DartEditMessage field0,
  ) = DartMessage_Edit;
  const factory DartMessage.iconChange(
    DartIconChangeMessage field0,
  ) = DartMessage_IconChange;
  const factory DartMessage.stopTyping() = DartMessage_StopTyping;
}

@freezed
class DartMessagePart with _$DartMessagePart {
  const factory DartMessagePart.text(
    String field0,
  ) = DartMessagePart_Text;
  const factory DartMessagePart.attachment(
    DartAttachment field0,
  ) = DartMessagePart_Attachment;
}

class DartMessageParts {
  final NativeLib bridge;
  final List<DartIndexedMessagePart> field0;

  const DartMessageParts({
    required this.bridge,
    required this.field0,
  });

  Future<String> asPlain({dynamic hint}) =>
      bridge.asPlainMethodDartMessageParts(
        that: this,
      );
}

class DartMMCSFile {
  final Uint8List signature;
  final String object;
  final String url;
  final Uint8List key;
  final int size;

  const DartMMCSFile({
    required this.signature,
    required this.object,
    required this.url,
    required this.key,
    required this.size,
  });
}

class DartNormalMessage {
  DartMessageParts parts;
  DartBalloonBody? body;
  String? effect;
  String? replyGuid;
  String? replyPart;

  DartNormalMessage({
    required this.parts,
    this.body,
    this.effect,
    this.replyGuid,
    this.replyPart,
  });
}

class DartReactMessage {
  final String toUuid;
  final int toPart;
  final bool enable;
  final DartReaction reaction;
  final String toText;

  const DartReactMessage({
    required this.toUuid,
    required this.toPart,
    required this.enable,
    required this.reaction,
    required this.toText,
  });
}

enum DartReaction {
  Heart,
  Like,
  Dislike,
  Laugh,
  Emphsize,
  Question,
}

@freezed
class DartRecievedMessage with _$DartRecievedMessage {
  const factory DartRecievedMessage.message({
    required DartIMessage msg,
  }) = DartRecievedMessage_Message;
}

class DartRenameMessage {
  final String newName;

  const DartRenameMessage({
    required this.newName,
  });
}

class DartUnsendMessage {
  final String tuuid;
  final int editPart;

  const DartUnsendMessage({
    required this.tuuid,
    required this.editPart,
  });
}

class MMCSTransferProgress {
  final int prog;
  final int total;
  final DartMMCSFile? file;

  const MMCSTransferProgress({
    required this.prog,
    required this.total,
    this.file,
  });
}

enum RegistrationPhase {
  NOT_STARTED,
  WANTS_USER_PASS,
  WANTS_VALID_ID,
  REGISTERED,
}

class TransferProgress {
  final int prog;
  final int total;
  final DartAttachment? attachment;

  const TransferProgress({
    required this.prog,
    required this.total,
    this.attachment,
  });
}
