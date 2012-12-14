.pragma library

/** Set value to storage */
function setKeyValue(key, value) {
    var db = openDatabaseSync("Nelisquare", "1.0", "Nelisquare settings database", 10);
    db.transaction(function(tx) {
       tx.executeSql('CREATE TABLE IF NOT EXISTS ' +
                     'settings(keyName TEXT, textValue TEXT)');
       var rs = tx.executeSql('SELECT keyName FROM settings WHERE keyName = "' + key + '"');
       var sql = "";
       var data = [ value, key ];
       if(rs.rows.length>0) {
           sql = "UPDATE settings SET textValue = '" + value + "' WHERE keyName = '" + key + "'";
       } else {
           sql = "INSERT INTO settings(textValue, keyName) VALUES ('" + value + "','" + key + "')";
       }
       tx.executeSql(sql);
    });
}

/** Get value from storage */
function getKeyValue(key, callback) {
    var db = openDatabaseSync("Nelisquare", "1.0", "Nelisquare settings database", 10);
    db.transaction(function(tx) {
       tx.executeSql('CREATE TABLE IF NOT EXISTS settings(keyName TEXT, textValue TEXT)');
       var result = "";
       var rs = tx.executeSql('SELECT textValue FROM settings WHERE keyName = "' + key + '"');
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

/** Truncate all data at storage */
function clear() {
    var db = openDatabaseSync("Nelisquare", "1.0", "Nelisquare settings database", 10);
    db.transaction(function(tx) {
        tx.executeSql('DELETE FROM SETTINGS');
    });
}
