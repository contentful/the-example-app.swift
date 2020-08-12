#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AppLinks.h"
#import "DPLDeepLink+AppLinks.h"
#import "DPLDeepLink.h"
#import "DPLMutableDeepLink+AppLinks.h"
#import "DPLMutableDeepLink.h"
#import "DeepLinkKit.h"
#import "DPLErrors.h"
#import "DPLTargetViewControllerProtocol.h"
#import "DPLRouteHandler.h"
#import "DPLDeepLinkRouter.h"

FOUNDATION_EXPORT double DeepLinkKitVersionNumber;
FOUNDATION_EXPORT const unsigned char DeepLinkKitVersionString[];

