//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSAddToProfileWhitelistOfferMessage.h"
#import "TSThread.h"

NS_ASSUME_NONNULL_BEGIN

// This is a deprecated class, we're keeping it around to avoid YapDB serialization errors
// TODO - remove this class, clean up existing instances, ensure any missed ones don't explode (UnknownDBObject)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
@implementation OWSAddToProfileWhitelistOfferMessage
#pragma clang diagnostic pop

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithUniqueId:(NSString *)uniqueId
             receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                          sortId:(uint64_t)sortId
                       timestamp:(uint64_t)timestamp
                  uniqueThreadId:(NSString *)uniqueThreadId
                   attachmentIds:(NSArray<NSString *> *)attachmentIds
                            body:(nullable NSString *)body
                    contactShare:(nullable OWSContact *)contactShare
                 expireStartedAt:(uint64_t)expireStartedAt
                       expiresAt:(uint64_t)expiresAt
                expiresInSeconds:(unsigned int)expiresInSeconds
                     linkPreview:(nullable OWSLinkPreview *)linkPreview
                  messageSticker:(nullable MessageSticker *)messageSticker
perMessageExpirationDurationSeconds:(unsigned int)perMessageExpirationDurationSeconds
  perMessageExpirationHasExpired:(BOOL)perMessageExpirationHasExpired
       perMessageExpireStartedAt:(uint64_t)perMessageExpireStartedAt
                   quotedMessage:(nullable TSQuotedMessage *)quotedMessage
                   schemaVersion:(NSUInteger)schemaVersion
                   customMessage:(nullable NSString *)customMessage
        infoMessageSchemaVersion:(NSUInteger)infoMessageSchemaVersion
                     messageType:(TSInfoMessageType)messageType
                            read:(BOOL)read
         unregisteredRecipientId:(nullable NSString *)unregisteredRecipientId
                       contactId:(NSString *)contactId
{
    self = [super initWithUniqueId:uniqueId
               receivedAtTimestamp:receivedAtTimestamp
                            sortId:sortId
                         timestamp:timestamp
                    uniqueThreadId:uniqueThreadId
                     attachmentIds:attachmentIds
                              body:body
                      contactShare:contactShare
                   expireStartedAt:expireStartedAt
                         expiresAt:expiresAt
                  expiresInSeconds:expiresInSeconds
                       linkPreview:linkPreview
                    messageSticker:messageSticker
perMessageExpirationDurationSeconds:perMessageExpirationDurationSeconds
    perMessageExpirationHasExpired:perMessageExpirationHasExpired
         perMessageExpireStartedAt:perMessageExpireStartedAt
                     quotedMessage:quotedMessage
                     schemaVersion:schemaVersion
                     customMessage:customMessage
          infoMessageSchemaVersion:infoMessageSchemaVersion
                       messageType:messageType
                              read:read
           unregisteredRecipientId:unregisteredRecipientId];

    if (!self) {
        return self;
    }

    _contactId = contactId;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

+ (instancetype)addToProfileWhitelistOfferMessageWithTimestamp:(uint64_t)timestamp thread:(TSThread *)thread
{
    return [[OWSAddToProfileWhitelistOfferMessage alloc]
        initWithTimestamp:timestamp
                 inThread:thread
              messageType:(thread.isGroupThread ? TSInfoMessageAddGroupToProfileWhitelistOffer
                                                : TSInfoMessageAddUserToProfileWhitelistOffer)];
}

- (BOOL)shouldUseReceiptDateForSorting
{
    // Use the timestamp, not the "received at" timestamp to sort,
    // since we're creating these interactions after the fact and back-dating them.
    return NO;
}

- (BOOL)isDynamicInteraction
{
    return YES;
}

@end

NS_ASSUME_NONNULL_END
