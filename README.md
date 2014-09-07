# Basic Guide to Shifts 

[![Code Climate](https://codeclimate.com/github/YaleSTC/shifts.png)](https://codeclimate.com/github/YaleSTC/shifts) 
[![Dependency Status](https://gemnasium.com/YaleSTC/shifts.svg)](https://gemnasium.com/YaleSTC/shifts)
[![Inline docs](http://inch-ci.org/github/yalestc/shifts.svg?branch=master)](http://inch-ci.org/github/yalestc/shifts)



The old README.md is stored on the [wiki](https://github.com/YaleSTC/shifts/wiki/Old-README.md) and the [website](https://yalestc.github.io/shifts/features/).

---

Shifts is a program that allows the easy tracking of employees who work scheduled (and even unscheduled) hours in various locations and times. It also offers payform features, allowing automatic logging of when employees work shifts, with the option for adding additional hours worked outside of shifts.

There are two sections of the application, one for employees who work shifts, and another for administrators, who manage these employees (Note: administrators can use the application as both administrators and employees, allowing them to perform administrative duties on top of using payforms, shifts, etc.)


Getting Started
===============

There are two mains steps to setting up Shifts: setting up a deployment server and installing the Shifts application.

### Prerequisites
You'll need the following to run Shifts:
* [Ruby 2.1.2](http://www.ruby-lang.org/)
* [Bundler](http://bundler.io/)
* a database server ([MySQL](http://www.mysql.com/))
* [ImageMagick](http://www.imagemagick.org/)

### Installation
First, checkout a copy of Shifts using git:

```sh
cd /your/code/directory
git clone https://github.com/YaleSTC/shifts.git
cd shifts
```

Shifts uses [Bundler](http://gembundler.com/) to manage dependencies, so if you don't have it, get it, then install dependencies:

```sh
gem install bundler
bundle install
```

Create `config/database.yml` - you'll need this to be able to connect to your database. Configure it with the correct username and password. Make a copy of the [`config/database.yml.example`](https://github.com/YaleSTC/shifts/blob/master/config/database.yml.example) and rename it to `config/database.yml` to start.

```sh
cp config/database.example.yml config/database.yml
```

Then, create the database and run migrations to build the structure:

```sh
rake db:create
rake db:schema:load
```

Finally, start the app locally:

```rails server```

Just point your browser to ```localhost:3000``` to use Shifts.

### Deploying to a Server

Shifts is built using [Ruby on Rails](http://rubyonrails.org/), and can be set up (deployed) like most Rails apps. You'll need a server running with the following software:

* [Ruby 2.1.2](http://www.ruby-lang.org/)
* database server ([MySQL](http://www.mysql.com/) is preferred, but any database supported by Rails should work, including PostgreSQL)
* web server ([apache](http://apache.org/) or [nginx](http://wiki.nginx.org/Main) both work well)
* Rails application server (we recommend [Phusion Passenger](https://www.phusionpassenger.com/))

For a general guide to setting up your web and application servers, including hosting providers, see the [Rails Deployment Guide](http://rubyonrails.org/deploy/).

Further Documentation
==================
* System administrators and end-users may like to review our [help documentation](https://yalestc.github.io/shifts).
* Developers interested in getting involved with *Shifts* can find information on our [project wiki](https://github.com/YaleSTC/shifts/wiki)

Suggestions and Issues
======================

If you have any suggestions, or would like to report an issue, please either:
* Create an issue for [this repository](https://github.com/YaleSTC/shifts/) on Github
* or, if you don't have a GitHub account, use our [issue submission form](https://docs.google.com/a/yale.edu/spreadsheet/viewform?formkey=dE8zTFprNVB4RTAwdURhWEVTTlpDQVE6MQ#gid=0)
