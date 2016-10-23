=======
History
=======

1.9.0 (2016-10-23)

**Features**

- New CSS structure that allows easy dashboard wide color customizations contributed by [rogersmj](https://community.home-assistant.io/users/rogersmj/activity)
- Added a favicon

**Fixes**

None

**Breaking Changes**

- Weather will not work unless Home Assistant is updated to use the Dark Sky component

1.8.1 (2016-10-09)
------------------

**Features**

- Updated weather to use Dark Sky sensors

**Fixes**

None

**Breaking Changes**

- Weather will not work unless Home Assistant is updated to use the Dark Sky component


1.8 (2016-10-09)
------------------

**Features**

- Add support for binary sensor contributed by [rogersmj](https://community.home-assistant.io/users/rogersmj/activity)

**Fixes**

None

**Breaking Changes**

None

1.7.5 (2016-18-16)
------------------

**Features**

None

**Fixes**

- Allow gridster to draw widgets larger than 5 columns - fix contributed by [mezz64](https://github.com/mezz64)

**Breaking Changes**

None

------------------

***Version 1.7.4***

- Modify IFrame widget for @jbardi and @robpitera

***Version 1.7.3***

- Add cover widget
- Garage widget is deprecated in favor of the cover widget and will be removed at some point
- Add location text to device_tracker widget

***Version 1.7.2***

- Change weather sensor names for 0.27.0

***Version 1.71***

- Remove decimals introduced by Hasensor text fix

***Version 1.7***

- Add Docker support contributed by [marijngiesen](https://github.com/marijngiesen)
- Add Raspberry PI Docker support contributed by [snizzleorg](https://community.home-assistant.io/users/snizzleorg/activity)
- Fix Hasensor to allow text fields fix suggested by [splnut](https://community.home-assistant.io/users/splnut/activity)

***Version 1.6***

- Merge Haalarm widgets contributed by [Soul](https://community.home-assistant.io/users/soul/activity)
- Allow Haweather units to be specified as a parameter

*Breaking Changes*

It is now necessary to explicitly specify the units for the weather widget or no units will be shown.

***Version 1.5.1***

- Fixed an issue with Float conversions on a weather field

*Changes in behavior*

`Wind Chill` on the weather widget has been replaced by `Apparent Temperature` which is now passed straight through from the sensor value.

***Version 1.5***

- Merge Hagroup contributed by [jwl173305361](https://community.home-assistant.io/users/jwl173305361/activity)
- Add background color support for all widgets

***Version 1.4***

- Addition of Halock contributed by [jwl173305361](https://community.home-assistant.io/users/jwl173305361/activity)
- Addition of Hasensor
- Addition of Hameter

*Breaking Changes*

None, however, Hasensor is intended as a replacement for Hatemp, Hahumidity and Halux, which are now deprecared and will be removed in a future release. Similarly, Hameter is intended to replace Hahumiditymeter.

***Version 1.3.2***

- Script buttons now light up for a configurable period when activated
- In order to accommodate the above change, functionality to run scripts and track the state of an input_select has been broken out into a new widget called `Hamode`

*Breaking Changes*

- Hascript no longer has the ability to track and display the state of an input_slelect. If you were using this functionality, change the type of your widget to `Hamode`


***Version 1.3.1***

- Scene buttons now light up for a configurable period when activated

***Version 1.3***

- Merge RSS widget contributed by [KRiS](https://community.home-assistant.io/users/kris/activity)
- Merge Hahumiditymeter contributed by [Shiv Chanders](https://community.home-assistant.io/users/chanders/activity)
- Allow temperature unit to be specified in the dasboard
- Remove main.erb and replace it with example.erb
- Update README to reflect new widgets
- Update README with additional install notes
- Update README with section on updating the dashboard

*Breaking Changes*

Previously temperature units defaulted to Fahrenheit - now there is no default, you must explicitly specify it in the Hatemp widget or you will get no units at all.

***Version 1.2.1***

- Minor typos in README

***Version 1.2***

- Fix docs and excample cfg to remove scheme from `hapush` dash_host config variable

***Version 1.1*** 

- Expand instructions
- Allow no api_key
- Allow http connections

***Version 1.0***

Initial Release
