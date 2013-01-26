#maemo5

#nelisquare contentaction
contentaction.files = $$PWD/nelisquare.xml
contentaction.path = /usr/share/contentaction
INSTALLS += contentaction

OTHER_FILES += $$PWD/nelisquare.xml

#nelisquare dbus service
service.files = $$PWD/com.nelisquare.service
service.path = /usr/share/dbus-1/services
INSTALLS += service

OTHER_FILES += $$PWD/com.nelisquare.service
