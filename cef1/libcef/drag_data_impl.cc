// Copyright (c) 2011 The Chromium Embedded Framework Authors. All rights
// reserved. Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

#include "libcef/drag_data_impl.h"
#include "base/file_path.h"

CefDragDataImpl::CefDragDataImpl(const WebDropData& data)
  : data_(data) {
}

bool CefDragDataImpl::IsLink() {
  return (data_.url.is_valid() && data_.file_description_filename.empty());
}

bool CefDragDataImpl::IsFragment() {
  return (!data_.url.is_valid() && data_.file_description_filename.empty() &&
          data_.filenames.empty());
}

bool CefDragDataImpl::IsFile() {
  return (!data_.file_description_filename.empty() || !data_.filenames.empty());
}

CefString CefDragDataImpl::GetLinkURL() {
  return data_.url.spec();
}

CefString CefDragDataImpl::GetLinkTitle() {
  return data_.url_title;
}

CefString CefDragDataImpl::GetLinkMetadata() {
  return data_.download_metadata;
}

CefString CefDragDataImpl::GetFragmentText() {
  return data_.text.is_null() ? CefString() : CefString(data_.text.string());
}

CefString CefDragDataImpl::GetFragmentHtml() {
  return data_.html.is_null() ? CefString() : CefString(data_.html.string());
}

CefString CefDragDataImpl::GetFragmentBaseURL() {
  return data_.html_base_url.spec();
}

CefString CefDragDataImpl::GetFileName() {
  return data_.file_description_filename;
}

bool CefDragDataImpl::GetFileNames(std::vector<CefString>& names) {
  if (data_.filenames.empty())
    return false;

  std::vector<WebDropData::FileInfo>::const_iterator it =
      data_.filenames.begin();
  for (; it != data_.filenames.end(); ++it)
    names.push_back(it->path);

  return true;
}
