---
created: 2013-03-27
title: How to redirect the Django Admin to https
slug: https-django-admin
author: Aron
tags: [python, django, https]
excerpt: Automatically redirect http requests for /admin to https
layout: article
---

    def walk_url_tree(urls):
        """
        Generator to walk a tree consisting of RegexURLPattern (with callback)
        and RegexURLResolver (with nested url_patterns).
        """
        for u in urls:
            if hasattr(u, 'url_patterns'):
                for u2 in walk_url_tree(u.url_patterns):
                    yield u2
            else:
                yield u
    
    # Enable the admin
    from django.contrib import admin
    admin.autodiscover()
    
    # Force admin to SSL: Resolve the admin.site.urls property then walk the
    # tree, wrapping the callbacks with ssl_required.
    ssl_admin_urls = admin.site.urls
    for u in walk_url_tree(ssl_admin_urls[0]):
        u._callback = ssl_required(u.callback)

    urlpatterns = patterns('layout.views',
        url(r'^admin/', include(admin.site.urls)),
    )

    urlpatterns = patterns('layout.views',
        url(r'^admin/', include(ssl_admin_urls)),
    )
