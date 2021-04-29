#******************************
# Created by Juan-Pablo Caceres
#******************************

CONFIG += c++11 console
CONFIG -= app_bundle

CONFIG += qt thread debug_and_release build_all
CONFIG(debug, debug|release) {
  TARGET = qjacktrip_debug
  } else {
  TARGET = qjacktrip
  }

QT += gui
QT += network
QT += widgets

# rc.1.2 switch enables experimental wair build, merge some of it with WAIRTOHUB
# DEFINES += WAIR
DEFINES += WAIRTOHUB

# http://wiki.qtcentre.org/index.php?title=Undocumented_qmake#Custom_tools
#cc DEFINES += __RT_AUDIO__
# Configuration without Jack
nojack {
  DEFINES += __NO_JACK__
}

# for plugins
INCLUDEPATH += faust-src-lair/stk

!win32 {
  INCLUDEPATH+=/usr/local/include
# wair needs stk, can be had from linux this way
# INCLUDEPATH+=/usr/include/stk
# LIBS += -L/usr/local/lib -ljack -lstk -lm
  LIBS += -L/usr/local/lib -ljack -lm
  nojack {
    message(Building NONJACK)
    LIBS -= -ljack
  }
}

macx {
  message(Building on MAC OS X)
  QMAKE_CXXFLAGS += -D__MACOSX_CORE__ #-D__UNIX_JACK__ #RtAudio Flags
  QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.9
  #QMAKE_MAC_SDK = macosx10.9
  CONFIG -= app_bundle
  #CONFIG += x86 #ppc #### If you have both libraries installed, you
  # can change between 32bits (x86) or 64bits(x86_64) Change this to go back to 32 bits (x86)
  LIBS += -framework CoreAudio -framework CoreFoundation -framework Foundation
  DEFINES += __MAC_OSX__
  CONFIG += objective_c
  }

linux-g++ | linux-g++-64 {
#   LIBS += -lasound -lrtaudio
  QMAKE_CXXFLAGS += -D__LINUX_ALSA__ #-D__LINUX_OSS__ #RtAudio Flags

FEDORA = $$system(cat /proc/version | grep -o fc)

contains( FEDORA, fc): {
  message(building on fedora)
}

UBUNTU = $$system(cat /proc/version | grep -o Ubuntu)

contains( UBUNTU, Ubuntu): {
  message(building on  Ubuntu)

# workaround for Qt bug under ubuntu 18.04
# gcc version 7.3.0 (Ubuntu 7.3.0-16ubuntu3)
# QMake version 3.1
# Using Qt version 5.9.5 in /usr/lib/x86_64-linux-gnu
  INCLUDEPATH += /usr/include/x86_64-linux-gnu/c++/7

# sets differences from original fedora version
  DEFINES += __UBUNTU__
}

  QMAKE_CXXFLAGS += -g -O2
  DEFINES += __LINUX__
  }

linux-g++ {
  message(Linux)
  QMAKE_CXXFLAGS += -D__LINUX_ALSA__ #-D__LINUX_OSS__ #RtAudio Flags
  }

linux-g++-64 {
  message(Linux 64bit)
  QMAKE_CXXFLAGS += -fPIC -D__LINUX_ALSA__ #-D__LINUX_OSS__ #RtAudio Flags
  }


win32 {
  message(Building on win32)
#cc  CONFIG += x86 console
  CONFIG += c++11 console
  exists("C:\Program Files\JACK2") {
    message("using Jack in C:\Program Files\JACK2")
    INCLUDEPATH += "C:\Program Files\JACK2\include"
    LIBS += "C:\Program Files\JACK2\lib\libjack64.lib"
    LIBS += "C:\Program Files\JACK2\lib\libjackserver64.lib"
  } else {
    exists("C:\Program Files (x86)\Jack") {
      message("using Jack in C:\Program Files (x86)\Jack")
      INCLUDEPATH += "C:\Program Files (x86)\Jack\includes"
      LIBS += "C:\Program Files (x86)\Jack\lib\libjack64.lib"
      LIBS += "C:\Program Files (x86)\Jack\lib\libjackserver64.lib"
    } else {
      message("Jack library not found")
    }
  }
#cc  QMAKE_CXXFLAGS += -D__WINDOWS_ASIO__ #-D__UNIX_JACK__ #RtAudio Flags
  #QMAKE_LFLAGS += -static -static-libgcc -static-libstdc++ -lpthread
  LIBS += -lWs2_32 #cc -lOle32 #needed by rtaudio/asio
  DEFINES += __WIN_32__
  DEFINES += _WIN32_WINNT=0x0600 #needed for inet_pton
  DEFINES += WIN32_LEAN_AND_MEAN
#cc    DEFINES -= UNICODE #RtAudio for Qt
}

DESTDIR = .
QMAKE_CLEAN += -r ./jacktrip ./jacktrip_debug ./release ./debug

# isEmpty(PREFIX) will allow path to be changed during the command line
# call to qmake, e.g. qmake PREFIX=/usr
isEmpty(PREFIX) {
 PREFIX = /usr/local
}
target.path = $$PREFIX/bin/
INSTALLS += target

# for plugins
INCLUDEPATH += faust-src-lair

# Input
HEADERS += src/DataProtocol.h \
           src/JMess.h \
           src/JackTrip.h \
           src/Effects.h \
           src/Compressor.h \
           src/CompressorPresets.h \
           src/Limiter.h \
           src/Reverb.h \
           src/AudioTester.h \
           src/jacktrip_globals.h \
           src/jacktrip_types.h \
           src/JackTripWorker.h \
           src/JitterBuffer.h \
           src/LoopBack.h \
           src/PacketHeader.h \
           src/ProcessPlugin.h \
           src/RingBuffer.h \
           src/RingBufferWavetable.h \
           src/Settings.h \
           src/UdpDataProtocol.h \
           src/UdpHubListener.h \
           src/AudioInterface.h \
           src/compressordsp.h \
           src/limiterdsp.h \
           src/freeverbdsp.h \
           src/about.h \
           src/messageDialog.h \
           src/qjacktrip.h \
           src/Patcher.h \
           src/SslServer.h \
           src/Auth.h
#(Removed JackTripThread.h JackTripWorkerMessages.h NetKS.h TestRingBuffer.h ThreadPoolTest.h)

!nojack {
HEADERS += src/JackAudioInterface.h
}
SOURCES += src/DataProtocol.cpp \
           src/JMess.cpp \
           src/JackTrip.cpp \
           src/Compressor.cpp \
           src/Limiter.cpp \
           src/Reverb.cpp \
           src/AudioTester.cpp \
           src/jacktrip_globals.cpp \
           src/JackTripWorker.cpp \
           src/JitterBuffer.cpp \
           src/LoopBack.cpp \
           src/PacketHeader.cpp \
           src/RingBuffer.cpp \
           src/Settings.cpp \
           src/UdpDataProtocol.cpp \
           src/UdpHubListener.cpp \
           src/AudioInterface.cpp \
           src/about.cpp \
           src/main.cpp \
           src/messageDialog.cpp \
           src/qjacktrip.cpp \
           src/Patcher.cpp \
           src/SslServer.cpp \
           src/Auth.cpp
#(Removed jacktrip_main.cpp jacktrip_tests.cpp JackTripThread.cpp ProcessPlugin.cpp)

!nojack {
SOURCES += src/JackAudioInterface.cpp
}

macx {
  HEADERS += src/NoNap.h
  OBJECTIVE_SOURCES += src/NoNap.mm
}

FORMS += src/qjacktrip.ui src/about.ui src/messageDialog.ui
RESOURCES += src/qjacktrip.qrc

# RtAduio Input
win32 {
  INCLUDEPATH += externals/rtaudio-4.1.1/include
  DEPENDPATH += externals/rtaudio-4.1.1/include
}
macx | win32 {
INCLUDEPATH += externals/rtaudio-4.1.1/
DEPENDPATH += externals/rtaudio-4.1.1/
HEADERS +=
SOURCES +=
}
