#!/usr/bin/env python3
"""Generate iOpencode.xcodeproj/project.pbxproj in JSON format (Xcode 15+)"""

import json
import hashlib

def uid(s):
    return hashlib.sha1(s.encode()).hexdigest()[:24].upper()

# ---- Object IDs ----
ROOT = uid("rootObject")
MAIN_GROUP = uid("mainGroup")
PRODUCTS_GROUP = uid("productsGroup")
SRC_GROUP = uid("srcGroup")
FW_GROUP = uid("fwGroup")
WWW_GROUP = uid("wwwGroup")
TARGET = uid("iOpencodeTarget")
TARGET_CONFIG_LIST = uid("targetConfigList")
PROJECT_CONFIG_LIST = uid("projectConfigList")
TARGET_DEBUG = uid("targetDebug")
TARGET_RELEASE = uid("targetRelease")
PROJ_DEBUG = uid("projDebug")
PROJ_RELEASE = uid("projRelease")
SRC_PHASE = uid("sourcesPhase")
FW_PHASE = uid("frameworksPhase")
RES_PHASE = uid("resourcesPhase")
EMBED_PHASE = uid("embedPhase")

objects = {}

def add_build_file(path, settings=None):
    ref = uid("fref-" + path)
    bld = uid("fbld-" + path)
    objects[ref] = {"isa": "PBXFileReference"}
    objects[bld] = {"isa": "PBXBuildFile", "fileRef": ref}
    if settings:
        objects[bld]["settings"] = settings
    return ref, bld

def add_source_file(path):
    r, b = add_build_file(path)
    objects[r].update({
        "lastKnownFileType": "sourcecode.swift",
        "name": path.split("/")[-1],
        "path": path,
        "sourceTree": "<group>"
    })
    return r, b

def add_resource_file(path, file_type):
    r, b = add_build_file(path)
    objects[r].update({
        "lastKnownFileType": file_type,
        "name": path.split("/")[-1],
        "path": path,
        "sourceTree": "<group>"
    })
    return r, b

def add_framework(path):
    r, b = add_build_file(path, {"ATTRIBUTES": ["CodeSignOnCopy", "RemoveHeadersOnCopy"]})
    objects[r].update({
        "lastKnownFileType": "wrapper.framework",
        "name": path.split("/")[-1],
        "path": path,
        "sourceTree": "<group>"
    })
    return r, b

# Source files
SRC_APPDELEGATE = add_source_file("AppDelegate.swift")
SRC_SCENEDELEGATE = add_source_file("SceneDelegate.swift")
SRC_VIEWCONTROLLER = add_source_file("ViewController.swift")
SRC_NODEBRIDGE = add_source_file("NodeBridge.swift")

# Resource files
RES_STORYBOARD = add_resource_file("Base.lproj/Main.storyboard", "file.storyboard")
RES_ASSETS = add_resource_file("Assets.xcassets", "folder.assetcatalog")

# Framework
FW_NODEMOBILE = add_framework("NodeMobile.framework")

# Product
PRODUCT_REF = uid("prod-ref")
objects[PRODUCT_REF] = {
    "isa": "PBXFileReference",
    "explicitFileType": "wrapper.application",
    "includeInIndex": 0,
    "path": "iOpencode.app",
    "sourceTree": "BUILT_PRODUCTS_DIR"
}

# Groups
objects[MAIN_GROUP] = {
    "isa": "PBXGroup",
    "children": [SRC_GROUP, FW_GROUP, PRODUCTS_GROUP, WWW_GROUP],
    "sourceTree": "<group>"
}
objects[SRC_GROUP] = {
    "isa": "PBXGroup",
    "children": [x[0] for x in [SRC_APPDELEGATE, SRC_SCENEDELEGATE, SRC_VIEWCONTROLLER, SRC_NODEBRIDGE, RES_STORYBOARD, RES_ASSETS]],
    "name": "iOpencode",
    "path": "iOpencode",
    "sourceTree": "<group>"
}
objects[FW_GROUP] = {
    "isa": "PBXGroup",
    "children": [FW_NODEMOBILE[0]],
    "name": "Frameworks",
    "sourceTree": "<group>"
}
objects[PRODUCTS_GROUP] = {
    "isa": "PBXGroup",
    "children": [PRODUCT_REF],
    "name": "Products",
    "sourceTree": "<group>"
}
objects[WWW_GROUP] = {
    "isa": "PBXGroup",
    "children": [],
    "name": "www",
    "path": "www",
    "sourceTree": "<group>"
}

# Build phases
objects[SRC_PHASE] = {
    "isa": "PBXSourcesBuildPhase",
    "buildActionMask": "2147483647",
    "files": [x[1] for x in [SRC_APPDELEGATE, SRC_SCENEDELEGATE, SRC_VIEWCONTROLLER, SRC_NODEBRIDGE]],
    "runOnlyForDeploymentPostprocessing": "0"
}
objects[FW_PHASE] = {
    "isa": "PBXFrameworksBuildPhase",
    "buildActionMask": "2147483647",
    "files": [FW_NODEMOBILE[1]],
    "runOnlyForDeploymentPostprocessing": "0"
}
objects[RES_PHASE] = {
    "isa": "PBXResourcesBuildPhase",
    "buildActionMask": "2147483647",
    "files": [RES_STORYBOARD[1], RES_ASSETS[1]],
    "runOnlyForDeploymentPostprocessing": "0"
}
objects[EMBED_PHASE] = {
    "isa": "PBXCopyFilesBuildPhase",
    "buildActionMask": "2147483647",
    "dstPath": "",
    "dstSubfolderSpec": 10,
    "files": [FW_NODEMOBILE[1]],
    "name": "Embed Frameworks",
    "runOnlyForDeploymentPostprocessing": "0"
}

# Configurations
base_build_settings = {
    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
    "CODE_SIGN_STYLE": "Automatic",
    "CURRENT_PROJECT_VERSION": "1",
    "GENERATE_INFOPLIST_FILE": "YES",
    "INFOPLIST_FILE": "iOpencode/Info.plist",
    "INFOPLIST_KEY_CFBundleDisplayName": "iOpencode",
    "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
    "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
    "INFOPLIST_KEY_UILaunchStoryboardName": "LaunchScreen",
    "INFOPLIST_KEY_UIMainStoryboardFile": "Main",
    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
    "FRAMEWORK_SEARCH_PATHS": ("$(inherited)", "$(PROJECT_DIR)"),
    "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
    "LD_RUNPATH_SEARCH_PATHS": ("$(inherited)", "@executable_path/Frameworks"),
    "MARKETING_VERSION": "1.0",
    "PRODUCT_BUNDLE_IDENTIFIER": "com.granttheant10.iOpencode",
    "PRODUCT_NAME": "iOpencode",
    "SWIFT_EMIT_LOC_STRINGS": "YES",
    "SWIFT_VERSION": "5.0",
    "TARGETED_DEVICE_FAMILY": "1,2"
}

objects[TARGET_DEBUG] = {
    "isa": "XCBuildConfiguration",
    "buildSettings": dict(base_build_settings, **{"PROVISIONING_PROFILE_SPECIFIER": ""}),
    "name": "Debug"
}
objects[TARGET_RELEASE] = {
    "isa": "XCBuildConfiguration",
    "buildSettings": dict(base_build_settings, **{"PROVISIONING_PROFILE_SPECIFIER": ""}),
    "name": "Release"
}

objects[TARGET_CONFIG_LIST] = {
    "isa": "XCConfigurationList",
    "buildConfigurations": [TARGET_DEBUG, TARGET_RELEASE],
    "defaultConfigurationIsVisible": 0,
    "defaultConfigurationName": "Release"
}

project_build_settings = {
    "ALWAYS_SEARCH_USER_PATHS": "NO",
    "CLANG_ANALYZER_NONNULL": "YES",
    "CLANG_CXX_LANGUAGE_STANDARD": "gnu++20",
    "CLANG_ENABLE_MODULES": "YES",
    "CLANG_ENABLE_OBJC_ARC": "YES",
    "COPY_PHASE_STRIP": "NO",
    "DEBUG_INFORMATION_FORMAT": "dwarf",
    "ENABLE_STRICT_OBJC_MSGSEND": "YES",
    "ENABLE_TESTABILITY": "YES",
    "GCC_DYNAMIC_NO_PIC": "NO",
    "GCC_OPTIMIZATION_LEVEL": "0",
    "GCC_PREPROCESSOR_DEFINITIONS": ("DEBUG=1", "$(inherited)"),
    "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
    "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
    "ONLY_ACTIVE_ARCH": "YES",
    "SDKROOT": "iphoneos",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone"
}
objects[PROJ_DEBUG] = {
    "isa": "XCBuildConfiguration",
    "buildSettings": project_build_settings,
    "name": "Debug"
}

release_project_settings = dict(project_build_settings)
release_project_settings.update({
    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
    "ENABLE_NS_ASSERTIONS": "NO",
    "ENABLE_TESTABILITY": "NO",
    "GCC_DYNAMIC_NO_PIC": "YES",
    "GCC_OPTIMIZATION_LEVEL": "s",
    "MTL_ENABLE_DEBUG_INFO": "NO",
    "ONLY_ACTIVE_ARCH": "NO",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "",
    "SWIFT_COMPILATION_MODE": "wholemodule",
    "SWIFT_OPTIMIZATION_LEVEL": "-O",
    "VALIDATE_PRODUCT": "YES"
})
del release_project_settings["GCC_PREPROCESSOR_DEFINITIONS"]
objects[PROJ_RELEASE] = {
    "isa": "XCBuildConfiguration",
    "buildSettings": release_project_settings,
    "name": "Release"
}

objects[PROJECT_CONFIG_LIST] = {
    "isa": "XCConfigurationList",
    "buildConfigurations": [PROJ_DEBUG, PROJ_RELEASE],
    "defaultConfigurationIsVisible": 0,
    "defaultConfigurationName": "Release"
}

# Target
objects[TARGET] = {
    "isa": "PBXNativeTarget",
    "buildConfigurationList": TARGET_CONFIG_LIST,
    "buildPhases": [SRC_PHASE, FW_PHASE, RES_PHASE, EMBED_PHASE],
    "buildRules": [],
    "dependencies": [],
    "name": "iOpencode",
    "productName": "iOpencode",
    "productReference": PRODUCT_REF,
    "productType": "com.apple.product-type.application"
}

# Project
objects[ROOT] = {
    "isa": "PBXProject",
    "attributes": {
        "BuildIndependentTargetsInParallel": "1",
        "LastSwiftUpdateCheck": "1620",
        "LastUpgradeCheck": "1620"
    },
    "buildConfigurationList": PROJECT_CONFIG_LIST,
    "compatibilityVersion": "Xcode 14.0",
    "developmentRegion": "en",
    "hasScannedForEncodings": "0",
    "knownRegions": ["en", "Base"],
    "mainGroup": MAIN_GROUP,
    "productRefGroup": PRODUCTS_GROUP,
    "projectDirPath": "",
    "projectRoot": "",
    "targets": [TARGET]
}

# Write as JSON pbxproj
doc = {
    "archiveVersion": "1",
    "classes": {},
    "objectVersion": "56",
    "objects": objects,
    "rootObject": ROOT
}

import os
os.makedirs("iOpencode.xcodeproj", exist_ok="YES")
with open("iOpencode.xcodeproj/project.pbxproj", "w") as f:
    json.dump(doc, f, indent=2)

print("Generated JSON-format project.pbxproj")
print(f"  Objects: {len(objects)}, Target: {TARGET}")
