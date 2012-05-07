/*
    Copyright 2011 - Tommi Laukkanen (www.substanceofcode.com)

    This file is part of NewsFlow.

    NewsFlow is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    NewsFlow is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with NewsFlow. If not, see <http://www.gnu.org/licenses/>.
*/

/** Set value to storage */
function setKeyValue(key, value) {
    var db = openDatabaseSync("SubstanceOfCodeNewsFlow", "1.0", "KeyValueStorage", 10);
    db.transaction(function(tx) {
       tx.executeSql('CREATE TABLE IF NOT EXISTS ' +
                     'KeyValueStorage(keyName TEXT, textValue TEXT)');
       var rs = tx.executeSql('SELECT keyName FROM KeyValueStorage WHERE keyName = "' + key + '"');
       var sql = "";
       var data = [ value, key ];
       if(rs.rows.length>0) {
           sql = "UPDATE KeyValueStorage SET textValue = '" + value + "' WHERE keyName = '" + key + "'";
       } else {
           sql = "INSERT INTO KeyValueStorage(textValue, keyName) VALUES ('" + value + "','" + key + "')";
       }
       tx.executeSql(sql);
    });
}

/** Get value from storage */
function getKeyValue(key, callback) {
    var db = openDatabaseSync("SubstanceOfCodeNewsFlow", "1.0", "KeyValueStorage", 10);
    db.transaction(function(tx) {
       tx.executeSql('CREATE TABLE IF NOT EXISTS KeyValueStorage(keyName TEXT, textValue TEXT)');
       var result = "";
       var rs = tx.executeSql('SELECT textValue FROM KeyValueStorage WHERE keyName = "' + key + '"');
       for (var i = 0; i < rs.rows.length; i++) {
           result = rs.rows.item(i).textValue;
           callback(key,result);
           return;
       }
       if(rs.rows.length==0) {
           callback(key,"");
       }
    });
}
