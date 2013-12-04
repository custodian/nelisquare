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

#include <QFile>
#include <QDateTime>
#include <QVariant>
#include <QDebug>
#include <QIODevice>

#include "httppostsendbuffer.h"

HttpPostSendbuffer::HttpPostSendbuffer(QObject *parent) :
    QIODevice(parent)
{
    encodingS = "utf-8";
    virtualSize = 0;
    fileName = "";
    filePath = "";
    fileMime = "";
    attachmentMarkerStartPos = -1;
    attachmentMarkerEndPos = -1;
}

QByteArray HttpPostSendbuffer::strToEnc(QString s)
{
  if (encodingS == "utf-8")
  {
    return s.toUtf8();
  }
  else
  {
    return s.toAscii();
  }
}


QString HttpPostSendbuffer::encoding()
{
  return encodingS;
}

void HttpPostSendbuffer::setEncoding(QString enc)
{
  if (enc=="utf-8" || enc=="ascii")
  {
    encodingS=enc;
  }
}

void HttpPostSendbuffer::addField(QString name, QString value)
{
  fieldNames.append(name);
  fieldValues.append(value);
}

void HttpPostSendbuffer::setFile(QString fieldName, QString fileName, QString mime)
{
    if (file.isOpen())
    {
        file.close();
    }
    file.setFileName(fileName);
    if (file.open(QIODevice::ReadOnly))
    {
        QString name;
        if (fileName.contains("/"))
        {
            int pos=fileName.lastIndexOf("/");
            name=fileName.right(fileName.length()-pos-1);

        }
        else if (fileName.contains("\\"))
        {
            int pos=fileName.lastIndexOf("\\");
            name=fileName.right(fileName.length()-pos-1);
        }
        else
        {
            name=fileName;
        }
        this->filePath = filePath;
        this->fileFieldName = fieldName;
        this->fileName = name;
        this->fileMime = mime;
    }
    else
    {
        this->filePath = "";
        this->fileFieldName = "";
        this->fileName = "";
        this->fileMime = "";
    }
}

void HttpPostSendbuffer::buildPostTemplate(QString &contentType, qlonglong &contentLength)
{
    if (!file.isOpen())
    {
        return;
    }
    internalBuffer.clear();
    seek(0);
    attachmentMarkerStartPos = -1;
    attachmentMarkerEndPos = -1;

    QString crlf="\r\n";
    qsrand(QDateTime::currentDateTime().toTime_t());
    QString boundaryMagicCookie = QVariant(qrand()).toString()+QVariant(qrand()).toString()+QVariant(qrand()).toString();
    QByteArray mimePartBoundary;
    QString boundary="---------------------------" + boundaryMagicCookie;
    QString endBoundary = crlf + "--" + boundary + "--" + crlf;
    contentType="multipart/form-data; boundary=" + boundary;
    boundary = "--" + boundary + crlf;

    mimePartBoundary = boundary.toAscii();
    bool first=true;
    for (int i=0; i<fieldNames.size(); i++)
    {
      internalBuffer.append(mimePartBoundary);
      if (first)
      {
        boundary = crlf + boundary;
        mimePartBoundary = boundary.toAscii();
        first = false;
      }
      internalBuffer.append(QString("Content-Disposition: form-data; name=\""+fieldNames.at(i)+"\""+crlf).toAscii());
      if (encodingS == "utf-8")
      {
          internalBuffer.append(QString("Content-Transfer-Encoding: 8bit" + crlf).toAscii());
      }
      internalBuffer.append(crlf.toAscii());
      internalBuffer.append(strToEnc(fieldValues.at(i)));
    }

    internalBuffer.append(mimePartBoundary);
    internalBuffer.append(QString("Content-Disposition: form-data; name=\"" +
                                  fileFieldName + "\"; filename=\""
                                  + fileName + "\""+crlf).toAscii());
    internalBuffer.append(QString("Content-Type: "+fileMime+crlf+crlf).toAscii());
    attachmentMarkerStartPos = internalBuffer.size();
    attachmentMarkerEndPos = attachmentMarkerStartPos + file.size();
    internalBuffer.append(endBoundary.toAscii());        
    virtualSize = internalBuffer.size() + file.size();
    contentLength = virtualSize;
    internalBufferReadPos = 0;
    emit readyRead();
}

qint64 HttpPostSendbuffer::readData(char *data, qint64 maxlen)
{    
    char currCh = 0x00;    
    int i = 0;
    //qDebug() << "readData requested chunk " << maxlen << "bytes.";
    for ( ; ; )
    {
        if (this->getChar(&currCh))
        {            
            *(data + i) = currCh;
            i++;
            if (i == maxlen)
            {
                return i;
            }
        }
        else
        {            
            emit readChannelFinished();
            return i;
        }
    }
}

qint64 HttpPostSendbuffer::writeData(const char *data, qint64 len)
{
    if (data != NULL)
    {
        return len;
    }
    return 0;
}

bool HttpPostSendbuffer::seek(qint64 pos)
{
    if (pos < virtualSize )
    {
        internalBufferReadPos = pos;
        return true;
    }
    return false;
}

qint64 HttpPostSendbuffer::bytesAvailable() const
{
    return (virtualSize - internalBufferReadPos);

}

qint64 HttpPostSendbuffer::size() const
{
    return virtualSize;
}

bool HttpPostSendbuffer::isSequential()
{
    return true;
}

bool HttpPostSendbuffer::isReadable()
{
    return true;
}

bool HttpPostSendbuffer::isOpen()
{
    return true;
}

bool HttpPostSendbuffer::atEnd() const
{
    return (internalBufferReadPos == virtualSize);
}

bool HttpPostSendbuffer::waitForReadyRead(int msecs)
{
    Q_UNUSED(msecs);
    return true;
}

QByteArray HttpPostSendbuffer::readAll()
{
    //return QByteArray();
    return internalBuffer;
}

QByteArray HttpPostSendbuffer::read(qint64 maxSize)
{
    Q_UNUSED(maxSize);
    return QByteArray();
}

bool HttpPostSendbuffer::getChar(char *c)
{
    if (!this->atEnd())
    {
        if ((internalBufferReadPos >= attachmentMarkerStartPos)
                && (internalBufferReadPos < attachmentMarkerEndPos ))
        {
            if (file.getChar(c))
            {
                internalBufferReadPos++;
            }
            else
            {
                return false;
            }
        }
        else if (internalBufferReadPos < attachmentMarkerStartPos)
        {
            *c = internalBuffer.at(internalBufferReadPos);
            internalBufferReadPos++;
        }
        else if (internalBufferReadPos >= attachmentMarkerEndPos)
        {
            *c = internalBuffer.at(internalBufferReadPos - (attachmentMarkerEndPos - attachmentMarkerStartPos));
            internalBufferReadPos++;
        }
        else
        {
            return false;
        }
        return true;
    }
    else
    {
        return false;
    }
}
