/*
    QT Cloud Drive, desktop application for connecting to Cloud Drive
    Copyright (C) 2011 Vasko Mitanov vasko.mitanov@hotmail.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.    
*/

#ifndef HTTPPOSTSENDBUFFER_H
#define HTTPPOSTSENDBUFFER_H

#include <QObject>
#include <QFile>
#include <QBuffer>
#include <QString>
#include <QStringList>

class HttpPostSendbuffer : public QIODevice
{
    Q_OBJECT
public:
    explicit HttpPostSendbuffer(QObject *parent = 0);    

    QString encoding();
    void setEncoding(QString enc);
    void addField(QString name, QString value);
    void setFile(QString fieldName, QString fileName, QString mime);
    void buildPostTemplate(QString &contentType, qlonglong &contentLength);
    bool seek(qint64 pos);
    bool getChar(char *c);
    qint64 size() const;
    bool isSequential();
    qint64 bytesAvailable() const;
    bool isReadable();
    bool isOpen();
    bool atEnd() const;
    bool waitForReadyRead(int msecs);
    QByteArray readAll();
    QByteArray read(qint64 maxSize);
    qint64 writeData(const char *data, qint64 len);
    qint64 readData(char *data, qint64 maxlen);


signals:

public slots:

protected:

private:
    QByteArray strToEnc(QString s);
    qint64 writeFileProlog(int fileIndex, char *data, qint64 maxlen);
    qint64 readDataFromCurrentFileIndex(char *data, qint64 maxlen);

private:
    QString encodingS;
    QByteArray internalBuffer;
    int internalBufferReadPos;
    QStringList fieldNames;
    QStringList fieldValues;
    QString fileFieldName;
    QString fileName;
    QString filePath;
    QString fileMime;
    QFile   file;
    qint64 virtualSize;

    qint64 attachmentMarkerStartPos;
    qint64 attachmentMarkerEndPos;
};

#endif // HTTPPOSTSENDBUFFER_H
