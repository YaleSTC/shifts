--- 
layout: page
title: Documentation
permalink: /user-doc/
---

What you want on this page depends on your role within the *Shifts* application.

## Admin

If you are an Admin, you might want to read more about:

* [Setting up the *Shifts* application](https://github.com/YaleSTC/shifts/blob/rails-3.2/README.md)
* [Managing App Configuration](/reservations/user-doc/managing-app-config/)
* [Managing Requirements](reservations/user-doc/managing-requirements/)
* [Managing Users](/reservations/user-doc/managing-users/)
* [Managing Emails](/reservations/user-doc/emails/)
* [Usage Reports](/reservations/user-doc/reports/)
* [Managing Announcements](/reservations/user-doc/announcements/)

## User

If you use Shifts to log your hours, you may be interested in these pages:  

* [General Shifts Info](http://weke.its.yale.edu/wiki/index.php/Shifts_Application)

<ul>
{% for page in site.pages %}
  {% if page.layout == 'user-page' %}  
    <li><a href="{{ page.url | prepend: site.baseurl }}">{{ page.title }}</a></li>
  {% endif %}
{% endfor %}
</ul>

## Developer

If you're a developer or are interested in modifying the Shifts application, you might want to see the setup instructions:

* [Development Setup](https://github.com/YaleSTC/shifts/wiki)

If you can't find an answer to your question in this documentation, please [report the issue](https://docs.google.com/a/yale.edu/spreadsheet/viewform?formkey=dE8zTFprNVB4RTAwdURhWEVTTlpDQVE6MQ#gid=0) to us!
