// Copyright (c) 2010 The Chromium Embedded Framework Authors.
// Portions copyright (c) 2006-2008 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "base/compiler_specific.h"

#include "third_party/webkit/webcore/config.h"

#include "browser_webkit_glue.h"

#undef LOG
#include "base/data_pack.h"
#include "base/file_util.h"
#include "base/logging.h"
#include "base/mac_util.h"
#include "base/path_service.h"
#include "grit/webkit_resources.h"
#include "webkit/glue/webkit_glue.h"
#include "webkit/glue/plugins/plugin_list.h"

namespace webkit_glue {
  
// Data pack resource. This is a pointer to the mmapped resources file.
static base::DataPack* g_resource_data_pack = NULL;
  
// Helper method for getting the path to the CEF resources directory.
FilePath GetResourcesFilePath() {
  FilePath path;
  // We need to know if we're bundled or not to know which path to use.
  if (mac_util::AmIBundled()) {
    PathService::Get(base::DIR_EXE, &path);
    path = path.Append(FilePath::kParentDirectory);
    return path.AppendASCII("Resources");
  } else {
    PathService::Get(base::DIR_SOURCE_ROOT, &path);
    path = path.AppendASCII("src");
    path = path.AppendASCII("cef");
    return path.AppendASCII("resources");
  }
}
  
string16 GetLocalizedString(int message_id) {
  base::StringPiece res;
  if (!g_resource_data_pack->GetStringPiece(message_id, &res)) {
    LOG(FATAL) << "failed to load webkit string with id " << message_id;
  }
  
  return string16(reinterpret_cast<const char16*>(res.data()),
                  res.length() / 2);
}
  
  
base::StringPiece NetResourceProvider(int key) {
  base::StringPiece res;
  g_resource_data_pack->GetStringPiece(key, &res);
  return res;
}  

base::StringPiece GetDataResource(int resource_id) {
  switch (resource_id) {
    case IDR_BROKENIMAGE: {
      // Use webkit's broken image icon (16x16)
      static std::string broken_image_data;
      if (broken_image_data.empty()) {
        FilePath path = GetResourcesFilePath();
        // In order to match WebKit's colors for the missing image, we have to
        // use a PNG. The GIF doesn't have the color range needed to correctly
        // match the TIFF they use in Safari.
        path = path.AppendASCII("missingImage.png");
        bool success = file_util::ReadFileToString(path, &broken_image_data);
        if (!success) {
          LOG(FATAL) << "Failed reading: " << path.value();
        }
      }
      return broken_image_data;
    }
    case IDR_TEXTAREA_RESIZER: {
      // Use webkit's text area resizer image.
      static std::string resize_corner_data;
      if (resize_corner_data.empty()) {
        FilePath path = GetResourcesFilePath();
        path = path.AppendASCII("textAreaResizeCorner.png");
        bool success = file_util::ReadFileToString(path, &resize_corner_data);
        if (!success) {
          LOG(FATAL) << "Failed reading: " << path.value();
        }
      }
      return resize_corner_data;
    }
      
    case IDR_SEARCH_CANCEL:
    case IDR_SEARCH_CANCEL_PRESSED:
    case IDR_SEARCH_MAGNIFIER:
    case IDR_SEARCH_MAGNIFIER_RESULTS:
    case IDR_MEDIA_PAUSE_BUTTON:
    case IDR_MEDIA_PLAY_BUTTON:
    case IDR_MEDIA_PLAY_BUTTON_DISABLED:
    case IDR_MEDIA_SOUND_FULL_BUTTON:
    case IDR_MEDIA_SOUND_NONE_BUTTON:
    case IDR_MEDIA_SOUND_DISABLED:
    case IDR_MEDIA_SLIDER_THUMB:
    case IDR_MEDIA_VOLUME_SLIDER_THUMB:
    case IDR_INPUT_SPEECH:
    case IDR_INPUT_SPEECH_RECORDING:
    case IDR_INPUT_SPEECH_WAITING:
      return NetResourceProvider(resource_id);
      
    default:
      break;
  }
  
  return base::StringPiece();
}

void GetPlugins(bool refresh, std::vector<WebPluginInfo>* plugins) {
  NPAPI::PluginList::Singleton()->GetPlugins(refresh, plugins);
}

void DidLoadPlugin(const std::string& filename) {
}

void DidUnloadPlugin(const std::string& filename) {
}
  
}  // namespace webkit_glue