//
//  SQLiteRequest.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/15.
//

import Foundation

struct SQLiteSql {
    let createTableItem = "create table if not exists item(itemid INTEGER not null primary key, username text, userimgurl text, itemname text, price INTEGER, description text, imgurl text, updatedate text)"
    let insertIntoItem = "insert into item(itemid, username, userimgurl, itemname, price, description, imgurl, updatedate) values(:itemid, :username, :userimgurl, :itemname, :price, :description, :imgurl, :updatedate)"
    let selectFromItem = "select * from item order by itemid desc"
}

struct SQLiteDocumentDirectoryPath {
    let item = "item.sqlite"
    let update = "update.txt"
}
