#!/usr/bin/make -f
# Makefile for DISTRHO Plugins #
# ---------------------------- #
# Created by falkTX
#

# NAME, OBJS_DSP and OBJS_UI have been defined before

include ../../Makefile.mk

# --------------------------------------------------------------
# Basic setup

TARGET_DIR = ../../bin

BUILD_C_FLAGS   += -I.
BUILD_CXX_FLAGS += -I. -I../../dpf/distrho -I../../dpf/dgl

# --------------------------------------------------------------
# Set plugin binary file targets

jack       = $(TARGET_DIR)/$(NAME)
ladspa_dsp = $(TARGET_DIR)/$(NAME)-ladspa.$(EXT)
dssi_dsp   = $(TARGET_DIR)/$(NAME)-dssi.$(EXT)
dssi_ui    = $(TARGET_DIR)/$(NAME)-dssi/$(NAME)_ui
lv2        = $(TARGET_DIR)/$(NAME).lv2/$(NAME).$(EXT)
lv2_dsp    = $(TARGET_DIR)/$(NAME).lv2/$(NAME)_dsp.$(EXT)
lv2_ui     = $(TARGET_DIR)/$(NAME).lv2/$(NAME)_ui.$(EXT)
vst        = $(TARGET_DIR)/$(NAME)-vst.$(EXT)

ifeq ($(WIN32),true)
dssi_ui += .exe
endif

# TODO: MacOS VST bundle

# --------------------------------------------------------------
# Set distrho code files

DISTRHO_PLUGIN_FILES = ../../dpf/distrho/DistrhoPluginMain.cpp
DISTRHO_UI_FILES     = ../../dpf/distrho/DistrhoUIMain.cpp ../../dpf/libdgl.a

# --------------------------------------------------------------
# Handle plugins without UI

ifeq ($(TARGET_NOUI),true)
dssi_ui =
lv2_ui =
DISTRHO_UI_FILES =
DGL_LIBS =
OBJS_UI =
endif

# --------------------------------------------------------------
# all needs to be first

all:

# --------------------------------------------------------------
# Common

clean:
	rm -f *.o
	rm -rf $(TARGET_DIR)/$(NAME) $(TARGET_DIR)/$(NAME)-* $(TARGET_DIR)/$(NAME).lv2/

# --------------------------------------------------------------
# JACK

jack: $(jack)

$(jack): $(OBJS_DSP) $(OBJS_UI) $(DISTRHO_PLUGIN_FILES) $(DISTRHO_UI_FILES)
	mkdir -p $(shell dirname $@)
	$(CXX) $^ $(BUILD_CXX_FLAGS) $(LINK_FLAGS) $(shell pkg-config --cflags --libs jack fftw3 mxml zlib ntk_images ntk x11) -DDISTRHO_PLUGIN_TARGET_JACK -o $@

# --------------------------------------------------------------
# LV2

lv2: $(lv2)

$(lv2): $(OBJS_DSP) $(OBJS_UI) $(DISTRHO_PLUGIN_FILES) $(DISTRHO_UI_FILES)
	mkdir -p $(shell dirname $@)
	$(CXX) $^ $(BUILD_CXX_FLAGS) $(LINK_FLAGS) $(shell pkg-config --cflags --libs fftw3 mxml zlib ntk_images ntk x11) $(SHARED) -DDISTRHO_PLUGIN_TARGET_LV2 -o $@

# --------------------------------------------------------------
# VST

vst: $(vst)

$(vst): $(OBJS_DSP) $(OBJS_UI) $(DISTRHO_PLUGIN_FILES) $(DISTRHO_UI_FILES)
	mkdir -p $(shell dirname $@)
	$(CXX) $^ $(BUILD_CXX_FLAGS) $(LINK_FLAGS) $(shell pkg-config --cflags --libs fftw3 mxml zlib ntk_images ntk x11) $(SHARED) -DDISTRHO_PLUGIN_TARGET_VST -o $@

# --------------------------------------------------------------
