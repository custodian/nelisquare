/*
 *
 */
.pragma library

api.log("loading api-venues...");

var venues = new ApiObject();
//venues.debuglevel = 1;

venues.loadVenues = function(page, query) {
    var url = "venues/search?" +
        getLocationParameter();
    if(query!=null && query.length>0) {
        url += "&query=" + encodeURIComponent(query);
    }
    url += "&" + getAccessTokenParameter();
    api.request("GET", url, page, venues.parseVenues);
    page.waiting_show();
}

venues.parseVenues = function(response, page) {
    var data = api.process(response, page);
    var count = 0;
    page.placesModel.clear();
    page.waiting_hide();
    data.venues.forEach(function(place) {
        //console.log("PLACE: " + JSON.stringify(place));
        var icon = "";
        if(place.categories!=null && place.categories[0]!==undefined) {
            icon = parseIcon(place.categories[0].icon);
        } else {
            icon = parseIcon(defaultVenueIcon);
        }
        page.placesModel.append({
                           "id": place.id,
                           "name": place.name,
                           "todoComment": "",
                           "distance": place.location.distance,
                           "address": parse(place.location.address),
                           "city": parse(place.location.city),
                           "lat": place.location.lat,
                           "lng": place.location.lng,
                           "icon": icon,
                           "peoplesCount": parse(place.hereNow.count),
                           "specialsCount": parse(place.specials.count)
        });
        count++;
    });
}

venues.loadVenuesExplore = function(page, query, section, specialsOnly, openNow, saved, sortByDistance, price, novelty) {
    var url = "venues/explore?" +
        getLocationParameter();
    if(query) {
        url += "&query=" + encodeURIComponent(query);
    }
    if(section) {
        url += "&section=" + encodeURIComponent(section)
    }
    url += "&specials=" + specialsOnly
    url += "&openNow=" + openNow
    url += "&saved=" + saved
    url += "&sortByDistance=" + sortByDistance
    if(price) {
        url += "&price=" + price
    }
    if(novelty) {
        url += "&novelty=" + novelty
    }
    url += "&" + getAccessTokenParameter();

    console.log("Venue URL: " + url);
    api.request("GET", url, page, venues.parseVenuesExplore);
    page.waiting_show();
}

venues.parseVenuesExplore = function(response, page) {
    var data = api.process(response, page);
    // console.log("response: " + response);
    var count = 0;
    page.placesModel.clear();
    page.waiting_hide();

    if(data.warning)
        page.show_info(data.warning.text)

    data.groups.forEach(function(group) {
        group.items.forEach(function(item) {
            //console.log("PLACE: " + JSON.stringify(place));
            var place = item.venue
            var icon = "";
            if(place.categories!=null && place.categories[0]!==undefined) {
                icon = parseIcon(place.categories[0].icon);
            } else {
                icon = parseIcon(defaultVenueIcon);
            }
            page.placesModel.append({
                               "id": place.id,
                               "name": place.name,
                               "todoComment": "",
                               "distance": place.location.distance,
                               "address": parse(place.location.address),
                               "city": parse(place.location.city),
                               "lat": place.location.lat,
                               "lng": place.location.lng,
                               "icon": icon,
                               "peoplesCount": parse(place.hereNow.count),
                               "specialsCount": parse(place.specials.count),
                               "group": group.type
            });
            // TODO plot venues on map
            count++;
        })
    })
}

venues.likeVenue = function(page, id, state) {
    console.log("LIKE VENUE: " + id + " STATE: " + state);
    var url = "venues/"+id+"/like?set="
    if (state) {
        url += "1";
    } else {
        url += "0";
    }
    url += "&" + getAccessTokenParameter();
    api.request("POST", url, page, venues.parseLikeVenue);
}

venues.parseLikeVenue = function(response, page) {
    //console.log("LIKE RESPONSE: " + JSON.stringify(response));
    var data = api.process(response, page);

    processLikes(page.likeBox, data);
}

venues.loadVenue = function(page, venueID) {
    var url = "venues/" + venueID + "?" + getAccessTokenParameter();
    page.waiting_show();
    page.venueID = venueID;
    page.venueName = "Loading";
    page.venueAddress = "";
    page.venueCity = "";
    page.venueMajor = "";
    page.photosBox.photosModel.clear();
    page.usersBox.photosModel.clear();
    page.venueMapLat = "";
    page.venueMapLng = "";
    api.request("GET", url, page, venues.parseVenue);
}

venues.parseVenue = function(response, page) {
    var data = api.process(response, page);
    //console.log("VENUE: "+ JSON.stringify(data));
    page.waiting_hide();
    var venue = data.venue;
    var icon = "";
    if(venue.categories!=null && venue.categories[0]!==undefined) {
        icon = venue.categories[0].icon;
    }
    page.venueID = venue.id;
    page.venueName = venue.name;
    page.venueAddress = parse(venue.location.address);
    page.venueCity = parse(venue.location.city);
    if (venue.categories[0]!== undefined)
        page.venueTypeUrl = parseIcon(venue.categories[0].icon);
    else
        page.venueTypeUrl = parseIcon(defaultVenueIcon);
    if(venue.mayor.count>0) {
        page.venueMajorCount = venue.mayor.count;
        page.venueMajor = makeUserName(venue.mayor.user);
        page.venueMajorPhoto = thumbnailPhoto(venue.mayor.user.photo,100);
        page.venueMajorID = venue.mayor.user.id;
    } else {
        page.venueMajor = "";
        page.venueMajorPhoto = "";
        page.venueMajorID = "";
    }
    if(venue.location!==undefined) {
        page.venueMapLat = venue.location.lat;
        page.venueMapLng = venue.location.lng;
    }
    // parse likes
    processLikes(page.likeBox, venue);

    // Parse venue tips
    page.tipsModel.clear();
    if(venue.tips.count>0) {
        //console.log("TIPS: "+JSON.stringify(venue.tips));
        venue.tips.groups.forEach(function (group) {
                group.items.forEach(function(tip) {
                    if (page.tipsModel.count <= 10)
                        addTipToModel(page,tip);
                })
            });
    }
    if(venue.photos.count>0) {
        page.photosBox.caption = venue.photos.summary;
        venue.photos.groups.forEach(function(group) {
            if (group.count>0) {
                group.items.forEach(function(photo){
                    page.photosBox.photosModel.append(
                        makePhoto(photo,300) );
                });
            }
        });
    }
    if (venue.hereNow.count>0) {
        page.usersBox.caption = venue.hereNow.summary;
        venue.hereNow.groups.forEach(function(group) {
            if (group.count>0) {
                group.items.forEach(function(user){
                    page.usersBox.photosModel.append({
                        "objectID": user.user.id,
                        "photoThumb": thumbnailPhoto(user.user.photo,100) });
                });
            }
        });
    }
    if (api.debugspecial) {
        page.specials = loaddebugspecial();
    }
    if (venue.specials.count>0) {
        page.specials = venue.specials;
    }
}

venues.loadVenuePhotos = function(page, venue) {
    page.waiting_show();

    var url = "/venues/" + venue + "/photos?group=checkin&offset="+page.options.get(0).offset+"&limit="+page.batchsize
    var url2 = "/venues/" + venue + "/photos?group=venue&offset="+page.options.get(1).offset+"&limit="+page.batchsize

    var urlfull = "multi?requests="
            + encodeURIComponent(url)
            + "," + encodeURIComponent(url2)
            + "&" + getAccessTokenParameter();

    api.request("GET", urlfull, page, venues.parseVenuePhotosGallery);
}

venues.parseVenuePhotosGallery = function(multiresponse, page) {
    var multidata = api.process(multiresponse);
    page.waiting_hide();
    for (var key in multidata.responses) {
        var data = multidata.responses[key].response;
        if (data.photos.items.length < page.batchsize) {
            page.options.get(key).completed = true;
        }
        page.options.get(key).offset += data.photos.items.length;
        page.loaded += data.photos.items.length;
        data.photos.items.forEach(function(photo){
            page.photosModel.append(
                makePhoto(photo,300)
            );
        });
    };
}

venues.addTip = function(page,venueID, text) {
    page.waiting_show();
    var url = "tips/add?";
    url += "venueId=" + venueID + "&";
    url += "text=" + encodeURIComponent(text) + "&";
    url += getAccessTokenParameter();
    api.request("POST", url, page, venues.parseAddTip);
}

venues.parseAddTip = function(response, page){
    var data = api.process(response, page);
    page.waiting_hide();
    addTipToModel(page,data.tip);
}

/*
//TODO: Move this stuff to lists
lists.markVenueToDo = function(venueID, text) {
    var url = "venues/" + venueID + "/marktodo?";
    if(text!="" && text.length>0) {
        url += "text=" + encodeURIComponent(text) + "&";
    }
    url += getAccessTokenParameter();
    api.request("POST", url, "", doNothing);
}

function loadToDo(page) {
    var url = "users/self/todos?" +
        getLocationParameter() + "&" +
        getAccessTokenParameter();
    page.waiting_show();
    doWebRequest("GET", url, page, parseToDo);
}

function parseToDo(response, page) {
    page.waiting_hide();
    var data = processResponse(response, page);
    page.placesModel.clear();
    data.todos.items.forEach(function(todo) {
        var place = todo.tip.venue;
        var icon = "";
        if(place.categories!=null && place.categories[0]!==undefined) {
            icon = parseIcon(place.categories[0].icon);
        } else {
            icon = parseIcon(defaultVenueIcon);
        }
        page.placesModel.append({
                           "id": place.id,
                           "name": place.name,
                           "todoComment": todo.tip.text,
                           "distance": place.location.distance,
                           "address": parse(place.location.address),
                           "city": parse(place.location.city),
                           "lat": place.location.lat,
                           "lng": place.location.lng,
                           "icon": icon,
                           "peoplesCount": 0
        });
    });
}
*/

venues.getCategoryInfoURL = function() {
    var url = API_URL + "venues/categories?locale="+api.locale+"&"+getAccessTokenParameter();
    return url;
}


venues.parseCategoryInfo = function(page,url) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var data = api.process(doc.responseText,page);
            page.categories = data.categories;
        }
    }
    doc.open("GET", url);
    doc.send();
}

venues.createVenue = function(page, params) {
    page.waiting_show();
    var url = "venues/add?";
    url += "primaryCategoryId="+params.category;
    url += "&name="+encodeURIComponent(params.name);
    if (params.address) {
        url += "&address="+encodeURIComponent(params.address);
    }
    url += "&ll=" + params.ll;
    url += "&" + getAccessTokenParameter();

    api.request("POST", url, page, venues.parseCreateVenue);
}

venues.parseCreateVenue = function(response, page) {
    var data = api.process(response,page);
    page.waiting_hide();
    var venue = data.venue;
    page.createCompleted(venue.id);
}

venues.prepareVenueEdit = function(page, venue) {
    venues.loadVenueCategories(function(response){
        page.venueCategories.clear();
        var data = api.process(response, page);
            data.categories.forEach(function(cat) {
                    console.log("CAT: " + cat.name)
                    cat.categories.forEach(function(sub) {
                        console.log(" -SUB: " + sub.name)
                });
            });
    });

    if (venue!=="") {
        //TODO: editing venue
    }
}
