/* -*- mode: C; c-file-style: "gnu"; indent-tabs-mode: nil; -*- */
/*
 * Copyright (C) 2017 Canonical Ltd
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 */

#pragma once

#include <shell/cc-panel.h>

#include <gio/gio.h>

G_BEGIN_DECLS

#define CC_TYPE_UBUNTU_PANEL (cc_ubuntu_panel_get_type ())
G_DECLARE_FINAL_TYPE (CcUbuntuPanel, cc_ubuntu_panel, CC, UBUNTU_PANEL, CcPanel)

typedef void (*CcUbuntuPanelExtensionStateChanged) (gboolean enabled, GObject *user_data);

void cc_ubuntu_panel_static_init_func (void);

#define CC_UBUNTU_PANEL_SHELL_EXTENSION_STATE_UNINSTALLED 99

void cc_ubuntu_panel_update_extension_widgets (GtkWidget  *extension_group,
                                               GtkWidget  *extension_switch,
                                               const char *uuid,
                                               int         extension_state,
                                               gboolean    always_show_switch);

gboolean cc_ubuntu_panel_util_is_extension_disabled (GSettings *gnome_shell_settings,
                                                     const char *uuid);
void cc_ubuntu_panel_util_set_extension_enabled (GSettings *gnome_shell_settings,
                                                 const char *uuid,
                                                 gboolean enabled);

G_END_DECLS
