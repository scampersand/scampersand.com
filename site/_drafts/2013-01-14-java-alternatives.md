---
created: 2013-01-14
title: Disable Java plugin in Fedora
slug: disable-java-plugin
author: Aron
tags: [java, fedora, security]
layout: article
---

    sudo alternatives --install \
        /usr/lib64/mozilla/plugins/libjavaplugin.so \
        libjavaplugin.so.x86_64 /dev/null 0
    sudo alternatives --set libjavaplugin.so.x86_64 /dev/null
    sudo alternatives --display libjavaplugin.so.x86_64

    libjavaplugin.so.x86_64 - status is manual.
     link currently points to /dev/null

    sudo alternatives --install \
        /usr/lib/mozilla/plugins/libjavaplugin.so \
        libjavaplugin.so /dev/null 0
    sudo alternatives --set libjavaplugin.so /dev/null
    sudo alternatives --display libjavaplugin.so

    libjavaplugin.so - status is manual.
     link currently points to /dev/null
