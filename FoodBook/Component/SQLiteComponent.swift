//
//  SQLiteRequest.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/15.
//

import Foundation

struct SQLiteSql {
    let createTableItem = "create table if not exists item(itemid INTEGER not null primary key, username text, userimgurl text, itemname text, price INTEGER, description text, imgurl text, updatedate text, commentcount INTEGER, likecount INTEGER, useritemlike INTEGER)"
    let insertIntoItem = "insert into item(itemid, username, userimgurl, itemname, price, description, imgurl, updatedate, commentcount, likecount, useritemlike) values(:itemid, :username, :userimgurl, :itemname, :price, :description, :imgurl, :updatedate, :commentcount, :likecount, :useritemlike)"
    let selectFromItem = "select * from item order by itemid desc"
    let createTableComment = "create table if not exists comment(commentid INTEGER not null primary key, itemid INTEGER, username text, userimgurl text, comment text, updatedate text)"
    let insertIntoComment = "insert into comment(commentid, itemid, username, userimgurl, comment, updatedate) values(:commentid, :itemid, :username, :userimgurl, :comment, :updatedate)"
    let selectFromComment = "select * from comment order by commentid desc"
}

struct SQLiteDocumentDirectoryPath {
    let item = "item.sqlite"
    let update = "update.txt"
    let comment = "comment"
    let sqlite = ".sqlite"
    let commentupdate = "commentupdate.txt"
}

struct LastUpdateParameterName {
    let update = "update"
    let lastupdate = "lastupdate"
    let commentupdate = "commentupdate"
    let commentlastupdate = "commentlastupdate"
}
